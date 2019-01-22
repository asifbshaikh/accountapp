namespace :product do
  desc "inventory missmatch for SMB plan"
  task :fix_inventory_mismatch=>:environment do
    Rails.logger.level = Logger::DEBUG
    company_id=8730
    products=Product.where(:company_id=>company_id, :inventory=>1)
    #products=Product.where(:company_id=>0, :id=>128552)
    i=0
    products.each do |product|
      available_quantity = product.quantity
      expected_quantity = product.opening_stock_on_date(Time.zone.now, nil)
      if available_quantity != expected_quantity
        puts"#{available_quantity} <> #{expected_quantity} Missmatch found and resolved for #{product.name}(#{product.id})"
        #stock.update_attribute("quantity", expected_quantity)
        i+=1
      end
    end
    puts"======= #{i} missmatch found and resolved ==========="
  end


  task :convert => :environment do
    # ActiveRecord::Base.transaction do
    companies = Company.all
    # company = Company.find 12
    puts "Hi, there are #{companies.count} companies"
    puts "*****Account that are not convert to product *****"
    Rails.logger.info "*****Account that are not convert to product *****"
    companies.each_with_index do |company, index|
      ActiveRecord::Base.transaction do
        rollback = false
        flag = true
        purchase_flag = true
        begin
          # step 1 - create new direct expese and direct income accounts
          direct_expense_head = AccountHead.find_by_company_id_and_name(company.id, "Direct Expenses")
          #Create sub account head  named "Purchase Account" under direct expense
          new_purchase_head = AccountHead.create!(:company_id => company.id, :parent_id => direct_expense_head.id, :name => "Purchase Account",
            :created_by => company.users.first.id)
          # Creating new expense account
          new_expense_account = Account.new(:company_id => company.id, :account_head_id => new_purchase_head.id,
           :name => "Purchase Account - default expense", :created_by => company.users.first.id)
          sub_account = DirectExpenseAccount.new(:inventoriable => false)
          new_expense_account.accountable = sub_account
          new_expense_account.save!
          new_expense_account.reload
        rescue Exception => e
          rollback = true
          puts" Error while creating account under direct expenses for company #{company.id } => #{e}"
          Rails.logger.info" Error while creating account under direct expenses for company #{company.id } => #{e}"
        end
        begin
          #Create sub account head named "Sales Account" under direct income
          direct_income_head = AccountHead.find_by_company_id_and_name(company.id, "Direct Income")
          new_sales_head = AccountHead.create!(:company_id => company.id, :parent_id => direct_income_head.id, :name => "Sales Account",
            :created_by => company.users.first.id)
          #Creating new income account
          new_income_account = Account.new(:company_id => company.id, :account_head_id => new_sales_head.id,
            :name => "Sales Account - default income", :created_by => company.users.first.id)
          sub_account = DirectIncomeAccount.new()
          new_income_account.accountable = sub_account
          new_income_account.save!
          new_income_account.reload
        rescue Exception => e
          rollback = true
          puts" Error while creating account under direct income for company #{company.id } => #{e}"
          Rails.logger.info" Error while creating account under direct income for company #{company.id } => #{e}"
        end

        sales_accounts = Account.get_product_or_service_accounts(company.id)
        purchase_accounts = Account.get_purchase_accounts(company.id)
        puts"Total purchase account = #{purchase_accounts.count} for company_id #{company.id}. Rejected purchase accounts are -"
        Rails.logger.info"Total purchase account = #{purchase_accounts.count} for company_id #{company.id}. Rejected purchase accounts are -"
        purchase_accounts.each do |account|
          user = User.find(account.created_by)

          # step 2 - create/replace product for newly created expense account
          @product = account.product
          type = account.accountable.reseller_product? ? "ResellerItem" : "PurchaseItem"
          if account.accountable.reseller_product?
            sales_price = account.accountable.sell_cost
          end
          begin
            if @product.blank?
              @product = Product.create!(:name => account.name, :company_id => company.id, :created_by => user.id,
              :branch_id => user.branch_id, :expense_account_id => new_expense_account.id,
              :purchase_price => account.accountable.unit_cost, :inventory => account.accountable.inventoriable,
              :type => type, :sales_price => sales_price, :description => account.accountable.description )
            else
              @product.update_attributes!(:name => account.name, :branch_id => user.branch_id,
              :expense_account_id => new_expense_account.id, :purchase_price => account.accountable.unit_cost,
              :inventory => account.accountable.inventoriable, :type => type, :sales_price => sales_price,
              :description => account.accountable.description )
            end
          rescue Exception => e
            rollback = true
            puts" Error while processing account #{account.id } => #{e}"
            Rails.logger.info" Error while processing account #{account.id } => #{e}"
          end
          #step 3 - Update all the tables having transaction with this account
          if @product.blank?
            puts" account = #{account.id}"
            Rails.logger.info" account = #{account.id}"
          else
            # Finding purchase_line_items for this purchase account and put product id in product_id column
            purchase_line_items = PurchaseLineItem.where(:account_id => account.id)
            purchase_line_items.update_all(:product_id => @product.id) unless purchase_line_items.blank?
            #Find payment_vouchers and replace account_id
            payment_vouchers = PaymentVoucher.where(:company_id => company.id, :to_account_id => account.id)
            payment_vouchers.update_all(:to_account_id => new_expense_account.id) unless payment_vouchers.blank?
            #Find journal_line_items and replace from_account_id
            journal_line_items = JournalLineItem.where(:from_account_id => account.id)
            journal_line_items.update_all(:from_account_id => new_expense_account.id ) unless journal_line_items.blank?
            #Find journal and replace account id
            journals = Journal.where(:company_id => company.id, :account_id => account.id )
            journals.update_all(:account_id => new_expense_account.id ) unless journals.blank?
            #Find saccounting_line_items and replace from_account_id
            saccounting_line_items = SaccountingLineItem.where(:from_account_id => account.id)
            saccounting_line_items.update_all(:from_account_id => new_expense_account.id) unless saccounting_line_items.blank?
            #Find saccounting and replace account_id
            saccountings = Saccounting.where(:company_id => company.id, :account_id => account.id)
            saccountings.update_all(:account_id => new_expense_account.id) unless saccountings.blank?
            #Find expense_line_items and replace account_id
            expense_line_items = ExpenseLineItem.where(:account_id => account.id)
            expense_line_items.update_all(:account_id => new_expense_account.id) unless expense_line_items.blank?
            #Find debit_notes and replace from_account_id
            debit_notes = DebitNote.where(:company_id => company.id, :from_account_id => account.id)
            debit_notes.update_all(:from_account_id => new_expense_account.id) unless debit_notes.blank?
            #Find credit_notes and replace from account id
            credit_notes = CreditNote.where(:company_id => company.id, :from_account_id => account.id)
            credit_notes.update_all(:from_account_id => new_expense_account.id) unless credit_notes.blank?
            # Find all ledgers having purchase account id and replace it with expense account id
            ledgers = Ledger.where(:company_id => company.id, :account_id => account.id)
            ledgers.update_all(:account_id => new_expense_account.id ) unless ledgers.blank?

            purchase_order_lines = PurchaseOrderLineItem.where(:account_id => account.id)
            purchase_order_lines.update_all(:product_id => @product.id) unless purchase_order_lines.blank?

            #step 4 - Mark this account as deleted
            account.update_attributes(:deleted => true, :deleted_by => user.id , :deleted_datetime => Time.now, :deleted_reason => "This account was converted to product")
          end
        end

        puts"Total sales accounts = #{sales_accounts.count} for company_id #{company.id}. Rejected sales accounts are -"
        Rails.logger.info"Total sales accounts = #{sales_accounts.count} for company_id #{company.id}. Rejected sales accounts are -"
        sales_accounts.each do |account|
          user = User.find(account.created_by)
          # step 2 - create/replace prodcut
          @product =  account.product
          begin
            if @product.blank?
              # Considering this sales account may reseller account
              @product = Product.find_by_company_id_and_name(company.id, account.name)
              if @product.blank?
                @product = Product.create!(:name => account.name, :company_id => company.id, :created_by => user.id,
                :branch_id => user.branch_id, :income_account_id => new_income_account.id,
                :sales_price => account.accountable.unit_cost, :inventory => account.accountable.inventoriable,
                :type => "SalesItem", :description => account.accountable.description)
              elsif @product.type == 'ResellerItem'
                @product.update_attributes!(:name => account.name, :branch_id => user.branch_id,
                :income_account_id => new_income_account.id, :sales_price => account.accountable.unit_cost,
                :inventory => account.accountable.inventoriable, :description => account.accountable.description)
              end
            else
              @product.update_attributes!(:name => account.name, :branch_id => user.branch_id,
              :income_account_id => new_income_account.id, :sales_price => account.accountable.unit_cost,
              :inventory => account.accountable.inventoriable, :type => "SalesItem", :description => account.accountable.description)
            end
          rescue Exception => e
            rollback = true
            puts" Error while processing account #{account.id } => #{e}"
            Rails.logger.info" Error while processing account #{account.id } => #{e}"
          end
          if @product.blank?
            flag = false
            puts" account = #{account.id}"
            Rails.logger.info" account = #{account.id}"
          end
          #step 3 - Update all the tables having transaction with this account
          unless @product.blank?
            #Find invoice_line_items and put product_id to these
            invoice_line_items = InvoiceLineItem.where(:account_id => account.id)
            invoice_line_items.update_all(:product_id => @product.id) unless invoice_line_items.blank?
            #Find journal_line_items and replace from_account_id
            journal_line_items = JournalLineItem.where(:from_account_id => account.id)
            journal_line_items.update_all(:from_account_id => new_income_account.id) unless journal_line_items.blank?
            #Find journals and replace account_id
            journals = Journal.where(:company_id => company.id, :account_id => account.id)
            journals.update_all(:account_id => new_income_account.id) unless journals.blank?
            #Find saccounting_line_items and replace from_account_id
            saccounting_line_items = SaccountingLineItem.where(:from_account_id => account.id)
            saccounting_line_items.update_all(:from_account_id => new_income_account.id ) unless saccounting_line_items.blank?
            #find saccountings and replace account_id
            saccountings = Saccounting.where(:company_id => company.id, :account_id => account.id)
            saccountings.update_all(:account_id => new_income_account.id) unless saccountings.blank?
            #Find receipt_vouchers and replace account_id
            receipt_vouchers = ReceiptVoucher.where(:company_id => company.id, :from_account_id => account.id)
            receipt_vouchers.update_all(:from_account_id => new_income_account.id) unless receipt_vouchers.blank?
            #Find debit_notes and replace from_account_id
            debit_notes = DebitNote.where(:company_id => company.id, :from_account_id => account.id)
            debit_notes.update_all(:from_account_id => new_income_account.id) unless debit_notes.blank?
            #Find credit_notes and replace from account id
            credit_notes = CreditNote.where(:company_id => company.id, :from_account_id => account.id)
            credit_notes.update_all(:from_account_id => new_income_account.id) unless credit_notes.blank?
            #Find income vouchers and replace from_account_id
            income_vouchers = IncomeVoucher.where(:company_id => company.id, :from_account_id => account.id)
            income_vouchers.update_all(:from_account_id => new_income_account.id) unless income_vouchers.blank?
            #Find all ledgers and replace account_id
            ledgers = Ledger.where(:company_id => company.id, :account_id => account.id)
            ledgers.update_all(:account_id => new_income_account.id ) unless ledgers.blank?

            estimate_lines = EstimateLineItem.where(:account_id => account.id)
            estimate_lines.update_all(:product_id => @product.id) unless estimate_lines.blank?

          end
        end
        #step 4 - Mark this account as deleted
        purchase_accounts.update_all(:deleted => true, :deleted_by => company.users.first.id , :deleted_datetime => Time.now, :deleted_reason => "This account was converted to product") unless purchase_accounts.blank?
        sales_accounts.update_all(:deleted => true, :deleted_by => company.users.first.id , :deleted_datetime => Time.now, :deleted_reason => "This account was converted to product") unless sales_accounts.blank?
        #step 5 - Mark purchase account head as deleted
        account_heads = AccountHead.where(:company_id => company.id, :name => "Purchase Accounts")
        purchase_account_heads = AccountHead.get_parent_and_child_heads(company.id, account_heads)
        purchase_account_heads.each do |purchase|
          purchase.update_attributes(:deleted => true, :deleted_by => company.users.first.id, :deleted_datetime => Time.now, :deleted_reason => "This head is moved in product" )
        end
        account_heads = AccountHead.where(:company_id => company.id, :name => "Products/Services")
        sales_account_heads = AccountHead.get_parent_and_child_heads(company.id, account_heads)
        sales_account_heads.each do |sale|
          sale.update_attributes(:deleted => true, :deleted_by => company.users.first.id, :deleted_datetime => Time.now, :deleted_reason => "This head is moved in product" )
        end
        if rollback
          puts"**** Transaction rollback for company #{company.id } ****"
          Rails.logger.info"**** Transaction rollback  for company #{company.id } ****"
          # raise ActiveRecord::Rollback
        end
      end
    end
    # end
  end
  task :update_estimates => :environment do
    est_account_ids = {"1" => '42', '2' => '90', '4' => '159', '5' => '182', '6'=>'186',
      '8'=>'222','9'=>'224','10'=>'222','11'=>'262','12'=>'303','14'=>'425','15'=>'296',
      '19'=>'924','20'=>'1000','21'=>'1001','22'=>'1005','23'=>'1003','24'=>'1010',
      '25'=>'1010','27'=>'1037','28'=>'1037','30'=>'490','31'=>'491','32'=>'1003','33'=>'1083',
      '34'=>'1158','36'=>'1048','38'=>'1212','40'=>'1215','42'=>'1421','44'=>'1617','45'=>'1623',
      '46'=>'1624','47'=>'1625','48'=>'1626','49'=>'1778','50'=>'1809','51'=>'1617','52'=>'1048',
      '53'=>'1617','54'=>'2181','55'=>'2183','57'=>'2290','58'=>'2290','59'=>'2291','60'=>'2376',
      '61'=>'2376'}
      puts"#{est_account_ids.count} records"
      est_account_ids.each do |key, value|
        account = Account.find_by_id(value.to_i)
        estimate_line = EstimateLineItem.find_by_id(key.to_i)
        if account.blank?
          estimate_line.destroy
        else
          product = account.product
          product = Product.find_by_name(account.name) if product.blank?
          estimate_line.update_attributes(:account_id => value.to_i, :product_id => product.id)unless product.blank?
        end
      end
  end
  task :update_purchase_order => :environment do
    order_acc_ids = {'1'=>'41','3'=>'89','5'=>'23','6'=>'23','7'=>'226','8'=>'226','9'=>'268',
      '11'=>'300','12'=>'693','13'=>'694','17'=>'1063','18'=>'1065','20'=>'1111','21'=>'1128',
      '22'=>'738','23'=>'1252','25'=>'1252','27'=>'1252','28'=>'1255','29'=>'1425','30'=>'1428',
      '31'=>'1429','32'=>'1978','33'=>'1990','34'=>'1988','35'=>'1992','36'=>'1994','37'=>'1996',
      '38'=>'2000','39'=>'1998','40'=>'2020','42'=>'2348'}
    puts"#{order_acc_ids.count} record"
    count = 0
    pcount = 0
    order_acc_ids.each do |key, value|
      account = Account.find_by_id(value.to_i)
      order_line = PurchaseOrderLineItem.find_by_id(key.to_i)
      if account.blank?
        count +=1
        order_line.destroy
      else
        product = account.product
        product = Product.find_by_name(account.name) if product.blank?
        if product.blank?
          pcount +=1
        else
          order_line.update_attributes(:account_id => value.to_i, :product_id => product.id)
        end
      end
    end
    puts"#{count} accounts not present and #{pcount} products are not found"
  end

  desc "update opening stock and unit price for batch enable products"
  task :update_batch_inventory => :environment do
    products = Product.where(:batch_enable=>true)
    products.each do |product|
      batches = ProductBatch.where(:company_id=> product.company_id, :product_id=>product.id, :opening_batch=>true)
      flag_hash=Hash.new
      batches.each do |product_batch|
        stock = Stock.where(:company_id => product.company_id, :product_id => product.id, :warehouse_id => product_batch.warehouse_id).first
        if !stock.blank?
          stock.opening_stock=0 if flag_hash[stock.id.to_s].blank?
          flag_hash[stock.id.to_s]="true"
          past_value=0
          past_value = stock.opening_stock*stock.opening_stock_unit_price unless stock.opening_stock.blank? || stock.opening_stock_unit_price.blank?
          current_value=0
          current_value = product_batch.quantity*product_batch.opening_stock_unit_price unless product_batch.quantity.blank? || product_batch.opening_stock_unit_price.blank?
          past_quantity=0
          past_quantity = stock.opening_stock unless stock.opening_stock.blank?
          current_quantity=0
          current_quantity=product_batch.quantity unless product_batch.quantity.blank?
          puts"avg_price = (#{past_value}+#{current_value})/(#{past_quantity}+#{current_quantity})"
          avg_price = (past_value+current_value)/(past_quantity+current_quantity)
          begin
            stock.update_attributes(:opening_stock => (stock.opening_stock + product_batch.quantity), :opening_stock_unit_price=>avg_price)
          rescue Exception => e
            stock.update_attributes(:opening_stock => (stock.opening_stock + product_batch.quantity), :opening_stock_unit_price=>0)
          end
        end
      end
    end
  end
  desc "To set value to as_on"
  task :update_as_on => :environment do
    products = Product.where(:inventory=>true)
    products.each do |product|
      if product.as_on.blank?
        company=product.company
        date=[]
        estimate=company.estimates.order_by("estimate_date ASC").joins(:estimate_line_items).where(:estimate_line_items=>{:product_id=>product.id}).first
        date<<estimate.estimate_date unless estimate.blank?
        invoice=company.invoices.order_by("invoice_date ASC").joins(:invoice_line_items).where(:invoice_line_items=>{:product_id=>product.id}).first
        date<<invoice.invoice_date unless invoice.blank?
        purchase=company.purchases.order_by("record_date ASC").joins(:purchase_line_items).where(:purchase_line_items=>{:product_id=>product.id}).first
        date<<purchase.record_date unless purchase.blank?
        purchase_order=company.purchase_orders.order_by("record_date ASC").joins(:purchase_order_line_items).where(:purchase_order_line_items=>{:product_id=>product.id}).first
        date<<purchase_order.record_date unless purchase_order.blank?
        stock_issue=company.stock_issue_vouchers.order_by("voucher_date ASC").joins(:stock_issue_line_items).where(:stock_issue_line_items=>{:product_id=>product.id}).first
        date<<stock_issue.voucher_date unless stock_issue.blank?
        stock_receipt=StockReceiptVoucher.order_by("voucher_date ASC").joins(:stock_receipt_line_items).where(:stock_receipt_line_items=>{:product_id=>product.id}).first
        date<<stock_receipt.voucher_date unless stock_receipt.blank?
        stock_transfer=StockTransferVoucher.order_by("voucher_date ASC").joins(:stock_transfer_line_items).where(:stock_transfer_line_items=>{:product_id=>product.id}).first
        date<<stock_transfer.voucher_date unless stock_transfer.blank?
        stock_wastage=StockWastageVoucher.order_by("voucher_date ASC").joins(:stock_wastage_line_items).where(:stock_wastage_line_items=>{:product_id=>product.id}).first
        date<<stock_wastage.voucher_date unless stock_wastage.blank?
        if product.created_at.to_date<date.min
          product.update_attribute("as_on", product.created_at.to_date)
        else
          product.update_attribute("as_on", date.min)
        end
      end
    end
  end
end
