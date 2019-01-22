namespace :invoice do

  #correct invoices that had zero entries due to changes in exchange rate
  desc "Populate customer id/vendor_id in invoices from account id"
  task :correct_invoice_zero_ledger_entries => :environment do
    invoices = Invoice.where("id=191809 and company_id=8663").where(" invoice_status_id IN (0, 2, 3, 4) AND deleted = 0")
    invoices.each do |invoice|
      puts "Invoice id #{invoice.id}"
      invoice.update_and_post_ledgers
    end
  end 
  
  desc "Populate customer id/vendor_id in invoices from account id"
  task :populate_customer_vendor_from_account => :environment do
    invoices = Invoice.all
    invoices.each do |invoice|
      if !invoice.cash_invoice?
        begin 
          if !invoice.account.customer.blank?
            invoice.update_attribute(:customer_id, invoice.account.customer.id)
            #invoice.save!
          elsif !invoice.account.vendor.blank?
            invoice.update_attribute(:vendor_id, invoice.account.vendor.id)
            invoice.save!
          end          
        rescue Exception => e
          puts "#{invoice.id}, #{invoice.invoice_number}, #{invoice.company_id} and error is #{e.message}"
        end
      end  
    end
  end
  

  desc "Change status of existing invoices that have returns as returned"
  task :mark_returned => :environment do
    invoice_returns = InvoiceReturn.all
    invoice_returns.each do |invoice_return|
      invoice = Invoice.find_by_id_and_company_id(invoice_return.invoice_id, invoice_return.company_id)
      if !invoice.nil?
        invoice.mark_return_status
      end
    end
  end

  desc "change status from draft of all sales warehouse details for non draft invoices"
  task :change_swd_status => :environment do
    sales_warehouse_details= SalesWarehouseDetail.joins(:invoice_line_item=>:invoice).where("invoices.invoice_status_id<>1 and draft=true")
    sales_warehouse_details.update_all(draft: false)
  end

  desc "Refresh Invoice"
  task :refresh => :environment do
    invoice_line_items=InvoiceLineItem.where("discount_percent>0").group("invoice_id")
    i=0
    j=0
    invoice_line_items.each do |line_item|
      invoice=line_item.invoice
      begin
        invoice.update_and_post_ledgers
        i+=1
      rescue Exception => e
        j+=1
      end
      print"#{i} invoices with discount has been refresh and #{j} failed\r"
    end
    puts"#{i} invoices with discount has been refresh and #{j} failed"
  end

  desc "Tax inclusive ledgers refresh"
  task :adjust_tax_inclusive => :environment do
    invoices = Invoice.where(:tax_inclusive=>true, :invoice_status_id=>[0,2,3])
    i=j=k=0
    invoices.each do |invoice|
      ledgers=invoice.ledgers
      if invoice.total_amount!=ledgers.sum(:debit)
        begin
          invoice.update_and_post_ledgers
          i+=1
        rescue Exception => e
          j+=1
        end
      else
        k+=1
      end
    end
    puts"#{i} invoices has been refresh, #{j} are not due to exception and #{k} are already created right way"
  end

  desc "migrating tax to double tax"
  task :migrate_into_double_tax => :environment do
    invoice_line_items = InvoiceLineItem.where("tax_account_id is not null")
    index=0
    invoice_line_items.each do |line_item|
      if line_item.invoice_taxes.blank?
        line_item.invoice_taxes<<InvoiceTax.new(:account_id=>line_item.tax_account_id)
        index+=1
      end
      print"Updating #{index} out of #{invoice_line_items.count}\r"
    end
    print"#{index} records updated out of #{invoice_line_items.count}"
    puts
  end

  desc "update financial year id"
  task :update_financial_year_id => :environment do
    invoices = Invoice.all
    i=0
    invoices.each do |invoice|
      company=invoice.company
      if company.financial_years.count>1
        invoice_date=invoice.invoice_date
        financial_year=company.financial_years.where("start_date<=? and end_date>=?", invoice_date, invoice_date).first
      else
        financial_year=company.financial_years.first
      end
      unless financial_year.blank?
        invoice.update_attribute("financial_year_id", financial_year.id)
        print"Updating... #{i} out of #{invoices.count}\r"
        i+=1
      end
    end
    puts"#{i} invoices updated out of #{invoices.count}"
  end
  task :update_product_id_in_sales_warehouse_details => :environment do
    sales_warehouse_details = SalesWarehouseDetail.all
    i=0
    ActiveRecord::Base.transaction do
      sales_warehouse_details.each do |swd|
        if swd.update_attribute(:product_id, swd.invoice_line_item.product_id)
          i+=1
        end
      end
    end
    puts"#{i} records updated out of #{sales_warehouse_details.count}"
  end

  task :update_total_amount => :environment do
    ActiveRecord::Base.transaction do
     # invoices = Invoice.all
    invoices = Invoice.where(:recursive_invoice=>2, :total_amount=>0)
    puts invoices.count
    invoices.each do |invoice|
      begin
        invoice.update_attribute(:total_amount, invoice.amount)
      rescue Exception => e
        puts"++++++Error in invoice(#{invoice.id})++++++"
        puts"#{e}"
      end
    end
   end
  end

  task :repeat => :environment do
    invoices = Invoice.where(:recursive_invoice => 1, :deleted => false, :invoice_status_id=>[0,2])
    puts"Total no of recursive invoices = #{invoices.count}"
    invoices.each do |invoice|
      if invoice.active_recursion? && !invoice.reached_recursion_count?  && invoice.schedule_on_today?
        company = invoice.company
        if company.active?
          if Invoice.new_recursive_invoice(invoice)
            puts"record save for company(id=#{company.id} #{company.name}) and invoie(id=#{invoice.id}) #{invoice.invoice_number}"
          else

          end
        end
      else

      end
    end
  end

  task :record_stock_change => :environment do
    ActiveRecord::Base.transaction do
      invoices = Invoice.where("created_at > ? and company_id != ?", "2013-09-02", 859) # company with 859 selects last warehouse and our bolowed logic is for companies first warehouse
      invoices.each do |invoice|
        invoice.invoice_line_items.each do |line_item|
          if line_item.inventoriable? && invoice.company.plan.is_inventoriable?
            if line_item.sales_warehouse_details.blank?
              product = line_item.product
              warehouse = invoice.company.warehouses.first
              puts"for comapny #{invoice.company.name}(#{invoice.company.id}), sales warehouse details saved for product=#{product.name}(#{product.id}), warehouse=#{warehouse.name}(#{warehouse.id}), quantity=#{line_item.quantity}"
              SalesWarehouseDetail.create!(:invoice_line_item_id => line_item.id,
                :warehouse_id => warehouse.id,
                :quantity => line_item.quantity)
              Stock.reduce(invoice.company.id, product.id, warehouse.id, line_item.quantity)
            end
          end
        end
      end
      #Here is code only for company 859
      invoices = Invoice.where("created_at > ? and company_id = ?", "2013-09-02", 859)
      puts"Only for 859"
      invoices.each do |invoice|
        invoice.invoice_line_items.each do |line_item|
          if line_item.inventoriable? && invoice.company.plan.is_inventoriable?
            puts"line_item.sales_warehouse_details.blank? = #{line_item.sales_warehouse_details.blank?}"
            if line_item.sales_warehouse_details.blank?
              product = line_item.product
              warehouse = invoice.company.warehouses.last
              puts"for comapny #{invoice.company.name}(#{invoice.company.id}), sales warehouse details saved for product=#{product.name}(#{product.id}), warehouse=#{warehouse.name}(#{warehouse.id}), quantity=#{line_item.quantity}"
              SalesWarehouseDetail.create!(:invoice_line_item_id => line_item.id,
                :warehouse_id => warehouse.id,
                :quantity => line_item.quantity)
              Stock.reduce(invoice.company.id, product.id, warehouse.id, line_item.quantity)
            end
          end
        end
      end
    end
  end

  task :customize_voucher_number => :environment do
    ActiveRecord::Base.transaction do
      company = Company.find(1136)
      invoices = Invoice.where(:company_id=>company.id)
      invoice_setting = InvoiceSetting.find_by_company_id(company.id)

      invoice_setting.update_attributes!(:invoice_no_strategy=>1, :invoice_sequence=>0, :invoice_prefix=>"13-14/GCS/TI")

      invoices.each do |invoice|
        voucher_number = company.invoice_setting.invoice_number
        invoice.update_attribute('invoice_number', voucher_number)
        invoice.reload
        invoice.ledgers.update_all(:voucher_number=>voucher_number)
      end
    end
  end

  desc "setting draft status for sales warehouse details "
  task :warehouse_detail_status => :environment do
    invoices = Invoice.where(:invoice_status_id=>1)
    invoices.each do |invoice|
      invoice.invoice_line_items.each do |line_item|
        line_item.sales_warehouse_details.each do |swd|
          swd.update_attribute("draft", true)
        end
      end
    end
  end

  desc "add account for invoice settlement"
  task :add_settlement_account => :environment do
    companies = Company.all
    i=0
    companies.each do |company|
      ActiveRecord::Base.transaction do
        account_head = AccountHead.find_by_name_and_company_id("Indirect Expenses", company.id)
        unless account_head.blank?
          exist_account=Account.find_by_name_and_company_id("Invoice Written Off Account", company.id)
          if exist_account.blank?
            account = Account.new(:company_id=> company.id,
              :account_head_id=> account_head.id,
              :name=>"Invoice Written Off Account",
              :created_by=>company.users.first.id
              )
            indirect_expense_account = IndirectExpenseAccount.new
            account.accountable=indirect_expense_account
            account.save!
            i+=1
          end
        end
      end
    end
    puts"#{i} accounts created out of #{companies.count}"
  end

  desc "update accoutable type for Invoice Written Off Account"
  task :update_settlement_account => :environment do
    companies = Company.all
    i=0
    companies.each do |company|
      exist_account=Account.find_by_name_and_company_id("Invoice Written Off Account", company.id)
      unless exist_account.blank?
        sub_account=IndirectExpenseAccount.new
        exist_account.accountable.delete unless exist_account.accountable.blank?
        exist_account.accountable=sub_account
        exist_account.save
        i+=1
      end
    end
    puts"#{i} accounts updated out of #{companies.count}"
  end

  desc "to add address as invoice attribut"
  task :add_addresses => :environment do
    invoices=Invoice.where(:cash_invoice=>false)
    success=0
    invoices.each do |invoice|
      begin
        customer = invoice.get_party
      rescue Exception => e
        customer=nil
      end
      unless customer.blank?
        customer_billing_address=customer.billing_address
        unless customer_billing_address.blank?
          invoice_billing_address=invoice.billing_address
          if invoice_billing_address.blank?
            billing_address=Address.new(:address_line1=>customer_billing_address.address_line1,
              :city=> customer_billing_address.city, :state=>customer_billing_address.state,
              :country=> customer_billing_address.country,
              :postal_code=> customer_billing_address.postal_code, :address_type=>1)
            invoice.billing_address=billing_address
          end
        end
        customer_shipping_address=customer.shipping_address
        unless customer_shipping_address.blank?
          invoice_shipping_address=invoice.shipping_address
          if invoice_shipping_address.blank?
            shipping_address=Address.new(:address_line1=>customer_shipping_address.address_line1,
              :address_type=>0)
            invoice.shipping_address=shipping_address
          end
        end
        success+=1
      end
    end
    puts"created #{success} out of #{invoices.count}"
  end
end
