namespace :setting do
  task :financial_year_entry => :environment do
    #Create new entry in years table for new financial year
    new_fin_year = Year.create(:name => "FY14")
    new_fin_year.reload

    @fin_years = FinancialYear.find_all_by_start_date("2012-04-01")
    puts @companies.inspect
    @fin_years.each do |fin_year|
      FinancialYear.create(:company_id => fin_year.company_id, :year_id => new_fin_year.id, :start_date => "2013-04-01", :end_date => "2014-03-31")
    end
  end

  task :subscription_update => :environment do
    ActiveRecord::Base.transaction do
    subscriptions = Subscription.where(:end_date => nil)
    subscriptions.each do |subscription|
      company = subscription.company
      unless company.blank?
        subscription.update_attributes(:start_date => company.created_at, :end_date => company.created_at + 1.months)
      end
    end
  end
  end

  task :account_balance_entry => :environment do
    financial_year = FinancialYear.find_by_company_id_and_freeze(469, true)
    financial_year.account_histories.each do |account_history|
      account = account_history.account
      account.update_attributes(:opening_balance => account_history.closing_balance)
    end
  end

  task :inventory_setting => :environment do
    ActiveRecord::Base.transaction do
      Company.all.each do |company|
        inventory_setting = InventorySetting.find_by_company_id(company.id)
        if inventory_setting.blank?
          InventorySetting.create!(:company_id => company.id,
            :purchase_effects_inventory => true)
        end
      end
	end
  end
  task :product_setting => :environment do 
    ActiveRecord::Base.transaction do 
      Company.all.each do |company|
        ProductSetting.create!(:company_id => company.id)
      end
    end
  end


  task :insert_company_to_purchase_warehouse_details => :environment do 
    ActiveRecord::Base.transaction do 
      PurchaseWarehouseDetail.all.each do |pwd|
        if pwd.purchase_line_item.blank?
          puts "No line_item present for #{pwd.id}"
        else
          company = pwd.purchase_line_item.purchase.company_id
          pwd.update_attributes!(:company_id => company)
        end
      end
    end
  end
  task :insert_company_to_sales_warehouse_details => :environment do 
    ActiveRecord::Base.transaction do 
      SalesWarehouseDetail.all.each do |swd|
        company = swd.invoice_line_item.invoice.company_id
        swd.update_attributes(:company_id => company) if swd.company_id.blank?
      end
    end
  end
  task :label_setting => :environment do
    ActiveRecord::Base.transaction do
      Company.all.each do |company|
        label_setting = Label.find_by_company_id(company.id)
        if label_setting.blank?
          Label.create!(:company_id => company.id,
                        :estimate_label => "Estimate", 
                        :warehouse_label=>"Warehouse", 
                        :customer_label => "Customer",
                        :created_by => company.users.first.id)
          puts"@@@ Label Terminology set for #{company.name}"
        else
          puts"@@@ #{company.name} already has terminology set "
        end
      end
    end
  end

  task :tds_receivable_head_switch => :environment do 
    ActiveRecord::Base.transaction do 
      Company.all.each do |company|
        parent_head = AccountHead.find_by_name_and_company_id("Duties and Taxes", company.id)
        new_parant_head = AccountHead.find_by_name_and_company_id("Other Current Assets", company.id)
        unless parent_head.blank? || new_parant_head.blank?
          tds_receivable_head = AccountHead.find_by_name_and_parent_id_and_company_id("TDS Receivable",parent_head.id, company.id)
          unless tds_receivable_head.blank?
            tds_receivable_account = tds_receivable_head.accounts.first
            other_current_asset = OtherCurrentAsset.new
            duties_and_taxes_account = tds_receivable_account.accountable
            tds_receivable_account.accountable = other_current_asset
            if tds_receivable_account.save!
              duties_and_taxes_account.delete
            end
            tds_receivable_head.update_attributes(:parent_id => new_parant_head.id)
          end
        end
      end
    end
  end

  task :set_opening_batches => :environment do
    products = Product.where(:inventory => true)
    products.each do |product|
      opening_stock = product.stocks.sum(:opening_stock)
      if opening_stock > 0
        if product.batch_enable?
          puts"#{opening_stock} quantity for #{product.name}(#{product.id}) in company #{product.company.name}(#{product.company.id})"
          puts"+++++++++++++++++++++++++++++++++++++++++++++"
          product.product_batches.each do |bp|
            if opening_stock > 0
              puts "#{bp.batch_number} having #{bp.quantity}"
              bp.update_attributes(:opening_batch => true, :opening_stock_unit_price => product.purchase_price)
              opening_stock -= bp.quantity
            end
          end
        puts"\n"
        else
          product.stocks.each do |stock|
            stock.update_attributes(:opening_stock_unit_price => product.purchase_price) unless stock.opening_stock.blank?
          end
        end
      end
    end
  end
    task :total_amount_to_expense => :environment do 
    ActiveRecord::Base.transaction do 
      Expense.all.each do |expense|
        begin
         expense.update_attribute(:total_amount, expense.amount)
       rescue
        puts"************Error********"
       end
      end
    end
  end

  task :total_amount_to_purchases => :environment do 
    ActiveRecord::Base.transaction do 
      Purchase.all.each do |purchase|
        begin
         f_year = FinancialYear.where("company_id=? and start_date <= ? and end_date >= ?", purchase.company_id,purchase.record_date.to_date,purchase.record_date.to_date).first
         purchase.fin_year = f_year.year.name
         purchase.update_attributes!(:total_amount => purchase.amount)
       rescue
        puts"************Error********"
       end
      end
    end
  end
 task :total_amount_to_invoices => :environment do 
    ActiveRecord::Base.transaction do 
      Invoice.all.each do |invoice|
        begin
         f_year = FinancialYear.where("company_id=? and start_date <= ? and end_date >= ?", invoice.company_id,invoice.invoice_date.to_date,invoice.invoice_date.to_date).first
         invoice.fin_year = f_year.year.name
         invoice.update_attributes!(:total_amount => invoice.amount)
       rescue Exception => e
        puts"************Error******** #{e} in invoice #{invoice.id}"
       end
      end
    end
  end
  task :total_amount_to_journal => :environment do 
    ActiveRecord::Base.transaction do 
      Journal.all.each do |journal|
        begin
         journal.update_attribute(:total_amount, journal.amount)
       rescue Exception => e
        puts"************Error******** #{e} in journal #{journal.id}"
       end
      end
    end
  end
task :total_amount_to_saccounting => :environment do 
    ActiveRecord::Base.transaction do 
      Saccounting.all.each do |saccounting|
        begin
         saccounting.update_attribute(:total_amount, saccounting.amount)
       rescue Exception => e
        puts"************Error******** #{e} in journal #{saccounting.id}"
       end
      end
    end
  end

  task :migrate_customer_vendor => :environment do
    ActiveRecord::Base.transaction do 
      customers = Account.where(:accountable_type=>"SundryDebtor", :customer_id=>nil)
      customers.each do |account|
        if account.customer.blank?
          puts "starting migration for account #{account.name}"
          customer = Customer.new
          customer.company_id = account.company.id
          customer.name = account.name
          customer.created_by = account.created_by
          if !account.accountable.nil?
            customer.phone_number = account.accountable.contact_number
            customer.email = account.accountable.email
            customer.pan = account.accountable.PAN
            customer.tan = account.accountable.tan
            customer.vat_tin = account.accountable.vat_tin
            customer.cst_reg_no  = account.accountable.cst 
            customer.excise_reg_no = account.accountable.excise_reg_no
            customer.service_tax_reg_no = account.accountable.service_tax_reg_no
            customer.website = account.accountable.website
            customer.fax = account.accountable.fax
            customer.country = account.accountable.country
            customer.weekly_off = account.accountable.weekly_off
            customer.cin = account.accountable.cin_code
            customer.bank_name = account.accountable.bank_name
            customer.ifsc_code = account.accountable.ifsc_code
            customer.micr_code = account.accountable.micr_code
            customer.bsr_code = account.accountable.bsr_code
            customer.credit_days = account.accountable.credit_days
            customer.credit_limit = account.accountable.credit_limit
            #customer.incorporated_date = account.accountable.incorporated_date
            customer.open_time = account.accountable.open_time
            customer.close_time = account.accountable.close_time
            customer.product_pricing_level_id = account.accountable.product_pricing_level_id
            customer.notes = account.accountable.notes
          end
          customer.account = account
          customer.save!
          
          puts "saved account with ID #{account.id} and name as #{account.name} as new customer with name #{customer.name}"
        end
      end
      vendors = Account.where(:accountable_type=>"SundryCreditor", :vendor_id=>nil)
      vendors.each do |account|
        if account.vendor.blank?
          puts "starting migration for account #{account.name}"
          vendor = Vendor.new
          vendor.company_id = account.company.id
          vendor.name = account.name
          if !account.accountable.nil?
            vendor.email = account.accountable.email
            vendor.pan = account.accountable.PAN
            vendor.sales_tax_no = account.accountable.sales_tax_number
            vendor.tan = account.accountable.tan
            vendor.vat_tin = account.accountable.vat_tin
            vendor.cst  = account.accountable.cst 
            vendor.excise_reg_no = account.accountable.excise_reg_no
            vendor.service_tax_reg_no = account.accountable.service_tax_reg_no
          end
          vendor.save!
          vendor.account = account
          puts "saved account with ID #{account.id} and name as #{account.name} as new vendor with name #{vendor.name}"
        end
      end
    end
  end
# task to create default invoice titles for smb plan companies
  task :create_title => :environment do
    ActiveRecord::Base.transaction do 
    @companies = Company.all
    @companies.each do |company|
      if company.plan.smb_plan? || company.plan.trial_plan?
        titles = ["Invoice","Tax Invoice"]
        titles.each do |title|
         voucher_title = VoucherTitle.find_by_voucher_title_and_company_id_and_voucher_type(title, company.id, "Invoice")
          if voucher_title.blank?
           VoucherTitle.create(:company_id => company.id, :voucher_title=> title ,:voucher_type=> "Invoice", :status=> true)
           puts "@@@  voucher title created for #{company.name}"
          else
             puts "@@@ #{company.name} already has voucher_title "
          end
        end
      end
    end
  end
  end
# task to update account on PN
task :update_account_cv => :environment do
 ActiveRecord::Base.transaction do   
   customer_accounts = CustomerAccount.all
   vendor_accounts = VendorAccount.all
   customer_accounts.each do |cust_acc|
    account = Account.find cust_acc.account_id
    customer = Customer.find cust_acc.customer_id
    account.update_attribute(:customer_id, customer.id)
   end
    puts"@@@ total #{customer_accounts.count} customer updated"
   vendor_accounts.each do |ven_acc|
      account = Account.find ven_acc.account_id
      vendor = Vendor.find ven_acc.vendor_id
      account.update_attribute(:vendor_id, vendor.id)
   end
   puts"@@@ total #{vendor_accounts.count} vendor updated"
 end
end

  task :create_voucher_setting => :environment do 
    ActiveRecord::Base.transaction do 
      companies = Company.all
      puts"Creating voucher number strategy for all companies....."
      companies.each do |company|
        voucher_settings = VoucherSetting.where(:company_id => company.id)
        if voucher_settings.blank?
         company.add_default_voucher_number_strategy
         puts"++added"
        else
           puts"++no need"
        end
      end
    end
  end
#  Voucher setting for new vouchers 
  task :update_voucher_setting => :environment do 
    ActiveRecord::Base.transaction do 
      companies = Company.all
      companies.each do |company|
        voucher_types = [19,20]
         voucher_types.each do |voucher_type|
         voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(company.id, voucher_type)
         if voucher_setting.blank?
          VoucherSetting.create!(:company_id=> company.id, :voucher_number_strategy=> 0,
          :voucher_type=> voucher_type )
          puts"Creating voucher number strategy for #{voucher_type} for company #{company.name}"
         else
           puts"Company #{company.name} already has right setting"
         end
         end
      end
    end
  end

  task :delete_voucher_setting => :environment do 
    ActiveRecord::Base.transaction do 
      companies = Company.all
      companies.each do |company|
        voucher_types = [19,20]
         voucher_types.each do |voucher_type|
         voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type_and_voucher_number_strategy_and_created_at(company.id, voucher_type, 0,   "2014-03-21 06:54:38")
         if voucher_setting.blank?
           puts"Company #{company.name} already has right setting"
         else
           voucher_setting.destroy
          puts"deleting voucher number strategy for #{voucher_type} for company #{company.name}"
         end
         end
      end
    end
  end


  task :update_subscription_for_free_plan => :environment do 
    ActiveRecord::Base.transaction do 
      free_plan_subscriptions = Subscription.where(:plan_id=>1)
      date = DateTime.new(2014, 2, 1)
      free_plan_subscriptions.each do |subscription|
        subscription.update_attributes(:end_date => (date + 1.years), :renewal_date => (date + 1.years))
      end
    end
  end
end
