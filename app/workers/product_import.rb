class ProductImport < ActiveRecord::Base
  include Sidekiq::Worker
  require 'date'
  require 'csv'
  require 'open-uri'
  belongs_to :import_file
  STATUS = {0 => "Failed",1 => "Success",2 => "Duplicate"}

  # @queue = :product_imports_queue
  def perform(file_id, company, user_id)
    import_file_id = file_id
    imported_file = ImportFile.find(file_id)
    file = CSV.parse(open(imported_file.file.url).read)

    file.drop(1).each do |row|
      product_code = row[0].gsub(/,/, '') unless row[0].blank?
      name = row[1].gsub(/,/, '') unless row[1].blank?
      description = row[2].gsub(/,/, '') unless row[2].blank?
      i_warehouse = row[3]
      quantity = row[4]
      batch_no = row[5]
      unit_price = row[6]
      reorder_level = row[7]
      unit = row[8]
      s_price = row[9]
      income_account = row[10]
      p_price = row[11]
      expense_account = row[12]
      product_tags = row[13]

      # Check if product is inventory enabled
      if !i_warehouse.blank? && !quantity.blank?
        warehouse_name = i_warehouse.strip
        warehouse = Warehouse.find_by_name_and_company_id(warehouse_name,company)
        if !warehouse.blank?
          warehouse_id = warehouse.id
        else
          created_warehouse = Warehouse.create(:name => warehouse_name, :company_id => company, :created_by => user_id)
          warehouse_id = created_warehouse.id
        end
        inventory = true
        if !batch_no.blank?
          batch = true
        else
          batch = false
        end
      else
        inventory = false
        batch = false
      end

      if !income_account.blank?
        sales_account_name = income_account.strip
        sales_account = Account.find_by_name_and_company_id(sales_account_name,company)
        if !sales_account.blank?
            income_account_id = sales_account.id
        else
          account_head = AccountHead.find_by_name_and_company_id("Direct Income",company)
          new_income_account = Account.new(:company_id => company, :account_head_id => account_head.id,
          :name => sales_account_name, :created_by => user_id)
          sub_account = DirectIncomeAccount.new()
          new_income_account.accountable = sub_account
          new_income_account.save
          income_account_id = new_income_account.id
        end
      end

      if !expense_account.blank?
        expense_account_name = expense_account.strip
        expense_account = Account.find_by_name_and_company_id(expense_account_name,company)
        if !expense_account.blank?
          expense_account_id = expense_account.id
        else
          account_head = AccountHead.find_by_name_and_company_id("Direct Expenses",company)
          new_expense_account = Account.new(:company_id => company, :account_head_id => account_head.id,
          :name => expense_account_name, :created_by => user_id)
          sub_account = DirectExpenseAccount.new(:inventoriable => false)
          new_expense_account.accountable = sub_account
          new_expense_account.save
          expense_account_id = new_expense_account.id
        end
      end
    
      product_import = ProductImport.new(:import_file_id => imported_file.id, :name => name,
        :description => description, :warehouse => i_warehouse, :quantity => quantity, 
        :batch_no => batch_no, :unit_price => unit_price, :reorder_level => reorder_level, 
        :unit_of_measure => unit, :sales_price => s_price, :income_account => income_account, 
        :purchase_price => p_price, :expense_account => expense_account)

      product = Product.new(:product_code => product_code,
          :name => name,:description => description,:reorder_level => reorder_level,
          :unit_of_measure => unit,:purchase_price => p_price,:sales_price => s_price,
          :inventory => inventory,:batch_enable => batch)
      product.company_id = company
      product.created_by = user_id
      product.income_account_id = income_account_id
      product.expense_account_id = expense_account_id
      if !income_account_id.blank? && !expense_account_id.blank?
        product.type = "ResellerItem"
      elsif !income_account_id.blank?
        product.type = "SalesItem"
      elsif !expense_account_id.blank?
        product.type = "PurchaseItem"
      else
        product.type = nil
      end
      if product_tags && product_tags.include?(";")
        product_tags.gsub!(";", ",")
      end
      product.tag_list = product_tags
      if product.valid?
        product.save
        product_import.status = 1
        product_import.save
        if product.batch_enable?
          pb = ProductBatch.new(:batch_number => batch_no,:company_id=> company,:opening_stock_unit_price=> unit_price,:product_id=>product.id,:quantity=> quantity,:warehouse_id => warehouse_id)
          product.product_batches << pb
          product.product_batches.each do |product_batch|
            stock = Stock.where(:company_id => company, :product_id => product.id, :warehouse_id => product_batch.warehouse_id).first
            if !stock.blank?
              past_value=0
              past_value = stock.opening_stock*stock.opening_stock_unit_price unless stock.opening_stock.blank? || stock.opening_stock_unit_price.blank?
              current_value=0
              current_value = product_batch.quantity*product_batch.opening_stock_unit_price unless product_batch.quantity.blank? || product_batch.opening_stock_unit_price.blank?
              past_quantity=0
              past_quantity = stock.opening_stock unless stock.opening_stock.blank?
              current_quantity=0
              current_quantity=product_batch.quantity unless product_batch.quantity.blank?
              avg_price = (past_value+current_value)/(past_quantity+current_quantity)
              stock.update_attributes(:opening_stock => (stock.opening_stock + product_batch.quantity), :opening_stock_unit_price=>avg_price)
            end
          end
        elsif product.inventory?
          stock = Stock.create!(:company_id=> company,:product_id=> product.id,:quantity=> quantity,:warehouse_id=>warehouse_id, :opening_stock => quantity,:opening_stock_unit_price => unit_price)
          product.stocks << stock
        end
      else
        product_import.status = 0
        product_import.save
      end
    end
    imported_file.update_attributes(:status => 1)
  end
end
