require 'csv'    
#require 'active_support/core_ext/hash'

namespace  :import do 
  #lib/tasks/import.rake
#   desc "Imports a CSV file into an ActiveRecord table"
#   task :csv_import => :environment do
#     #csv_text = File.read('coupons.csv')
#     #csv_text = File.read('coupons.csv')
#      lines = File.new('currency_codes.csv').readlines
#  header = lines.shift.strip
#   keys = header.split(',')
#   lines.each do |line|
#     values = line.strip.split(',')
#     attributes = Hash[keys.zip values]
#     Currency.create(attributes)
#   end
# #    csv = CSV.parse(csv_text, :headers => true)    
#     #CSV.foreach('coupons.csv', :headers => true) do |row|
# #    csv.each do |row|    
# #      puts "#{row}"
# #      Coupon.create!(Hash[row].with_indifferent_access)
# #    end  
#   end

# task :country_import => :environment do
#  ActiveRecord::Base.transaction do
#   @environment = ENV['RACK_ENV'] || 'development'
#   @dbconfig = YAML.load(File.read('config/database.yml'))
#   ActiveRecord::Base.establish_connection @dbconfig[@environment]

#   csv = CSV.read("#{Rails.root}/country_isd.csv")
#   puts"csv.first = #{csv.first.class}"
#   success = 0
#   fail = 0
#   count = 0
#   csv.each do |row|
#     if csv.first == row
#      puts"@@@ first csv row is #{csv.first == row}"
#    else
#      # if !row.blank? 
#      #    country = Country.new(:name => row[0], :isd_code => row[1], :currency_unicode => row[2], :currency_code => row[3])
#      #    country.save!
#      #    success += 1
#      #   else
#      #    fail += 1
#      #  end
#        count += 1
#       puts"@@@ name : #{row[0]},isd_code:#{row[1]}, currency_unicode:#{row[2]}, curre
#       : #{row[3]}"
#     end
#    end

#   puts"#{success} inserted and #{fail} fails amongs #{count} items"
# end

 task :product_import => :environment do

  csv = CSV.read("#{Rails.root}/Varad_Product List.csv")
 puts"csv.first = #{csv.first.class}"
 success = 0
 fail = 0
 count = 0
 csv.each do |row|
 if csv.first == row
   puts"@@@ first csv row is #{csv.first == row}"
 else
      company = Company.find_by_id(1717)
      user = company.users.first
      expense_account = Account.find_by_name_and_company_id("Purchase Account - default expense", company.id)
      income_account = Account.find_by_name_and_company_id("Sales Account - default income", company.id)
      if !row.blank? && !expense_account.blank? && !income_account.blank?
        product = Product.new(:name => row[0], :reorder_level => row[2], :description => row[1], :unit_of_measure => row[3], :purchase_price=> row[4],:sales_price => row[5])
        product.company_id = company.id
        product.created_by = user.id
        product.inventory = 1
        product.type = "PurchaseItem"
        product.expense_account_id = expense_account.id
        product.income_account_id = income_account.id
        product.save!
       success += 1
      else
       fail += 1
     end
      count += 1
     puts"@@@ name : #{row[0]}, reo_l:#{row[2]}, des:#{row[1]}, uom: #{row[3]}, purchase_price:#{row[4]}, sale_price : #{row[5]} "
  end
 end
 puts"#{success} inserted and #{fail} fails amongs #{count} items"
 end

# task :vendor_import => :environment do
#   @environment = Rails.env.production? || 'development'
#   @dbconfig = YAML.load(File.read('config/database.yml'))
#   ActiveRecord::Base.establish_connection @dbconfig[@environment]
# csv = CSV.read("#{Rails.root}/quality_corner_distributor.csv")
# puts"csv.first = #{csv.first.class}"
# success = 0
# fail = 0
# count = 0
# csv.each do |row|
# if csv.first == row
#   puts"@@@ first csv row is #{csv.first == row}"
# else
#      company = Company.find_by_id(822)
#      user = company.users.first
#       account_head = AccountHead.find_by_name_and_company_id("Vendors (Creditors)", company.id)    
#        if !row.blank? && !account_head.blank?
#          account = Account.new(:name => row[0])
#          account.company_id = company.id
#          account.created_by = user.id
#          account.account_head_id = account_head.id
#          sub_account = SundryCreditor.new()
#          account.accountable = sub_account
#          if !account.accountable_type.blank?
#           account.save!
#           puts"@@@@ account saved with accountable type"
#          else
#           puts"@@@@ something went wrong"
#          end
#         success += 1
#        else
#         fail += 1
#       end
#      count += 1
#     puts"@@@vendor acc name : #{row[0]}"
#  end
# end
# puts"#{success} inserted and #{fail} fails amongs #{count} items"
# end
task :create_product_and_warehouse_for_mmd => :environment do
  ActiveRecord::Base.transaction do
#    @environment = Rails.env.production? || 'development'
#    @dbconfig = YAML.load(File.read('config/database.yml'))
#    ActiveRecord::Base.establish_connection @dbconfig[@environment]
    success = 0
    fail = 0
    company = Company.find_by_id(768)
    user = company.users.first
    warehouse = Warehouse.create_default_warehouse(company.id, user.id)
    if !warehouse.blank?
     puts"@@@ warehouse added"
    end
    expense_account = Account.find_by_name_and_company_id("Purchase Account - default expense", company.id)
    income_account = Account.find_by_name_and_company_id("Sales Account - default income", company.id)
      if !expense_account.blank? && !income_account.blank?
        product = Product.new(:name => "books")
        product.company_id = company.id
        product.created_by = user.id
        product.inventory = 1
        product.type = "ResellerItem"
        product.expense_account_id = expense_account.id
        product.income_account_id = income_account.id
        product.save!
       success += 1
       puts"@@@ product added"
      else
       fail += 1
     end

  end  
end

task :purchase_for_mmd => :environment do 
  ActiveRecord::Base.transaction do
#    @environment = Rails.env.production? || 'development'
#    @dbconfig = YAML.load(File.read('config/database.yml'))
#    ActiveRecord::Base.establish_connection @dbconfig[@environment]
    csv = CSV.read("#{Rails.root}/saga_purchase.csv")
    puts"csv.first = #{csv.first.class}"
    success = 0
    fail = 0
    count = 0
    csv.each do |row|
    if csv.first == row
      puts"@@@ first csv row is #{csv.first == row}"
    else
        company = Company.find_by_id(768)
        year = company.get_current_financial_year
        user = company.users.first
        vendor = Account.find_by_id_and_company_id(12120, 768)
        warehouse = company.warehouses.first
        product = company.products.first
        if !row.blank? 
         purchase = Purchase.new(:record_date => row[1], :due_date=> row[1], :custom_field1=> row[6])
         purchase.account_id = vendor.id
         purchase.company_id = company.id
         purchase.created_by = user.id
         purchase.purchase_number = "PUR"+Time.now.to_i.to_s
         purchase.status_id = 0
         purchase.fin_year = year.name

          line_item = PurchaseLineItem.new()
          line_item.product_id = product.id
          line_item.quantity = 1
          line_item.unit_rate = row[5].to_f
          line_item.amount = row[5].to_f
          line_item.type = "PurchaseLineItem"
          
           
           purchase.purchase_line_items << line_item
          
        if purchase.save_with_ledgers
         if company.inventory_setting.purchase_effects_inventory?
            purchase.purchase_line_items.each do |line_item|
               purchase_warehouse_detail = PurchaseWarehouseDetail.new(:warehouse_id => warehouse.id, :quantity => 1, :company_id=>company.id)
               line_item.purchase_warehouse_details << purchase_warehouse_detail
              if line_item.inventoriable? && company.plan.is_inventoriable?
                product = line_item.product
                line_item.purchase_warehouse_details.each do |pwd|
                    Stock.increase(company.id, product.id, pwd.warehouse_id, pwd.quantity, line_item.unit_rate)
                end
              end
            end 
          end
        end
          success += 1
         else
          fail += 1
        end
         count += 1
         sleep(0.5)
        puts"@@@ record_date : #{row[1]}, due_date:#{row[1]}, order_no:#{row[6]}, unit_rate: #{row[5]} " 
     end
  end
end
puts"purchase inserted successfully"
end 

task :invoice_for_mmd => :environment do 
  ActiveRecord::Base.transaction do
#    @environment = Rails.env.production? || 'development'
#    @dbconfig = YAML.load(File.read('config/database.yml'))
#    ActiveRecord::Base.establish_connection @dbconfig[@environment]
    csv = CSV.read("#{Rails.root}/saga_invoice.csv")
    puts"csv.first = #{csv.first.class}"
    success = 0
    fail = 0
    count = 0
    csv.each do |row|
    if csv.first == row
      puts"@@@ first csv row is #{csv.first == row}"
    else
        company = Company.find_by_id(768)
        year = company.get_current_financial_year
        user = company.users.first
        cash_acc = Account.find_by_id_and_company_id(12095, 768)
        warehouse = company.warehouses.first
        product = company.products.first
       
        if !row.blank? 
         invoice = Invoice.new(:invoice_date => row[1], :due_date=> row[1], :custom_field1=> row[2])
         invoice.account_id = cash_acc.id
         invoice.company_id = company.id
         invoice.created_by = user.id
         invoice.invoice_number = "INV"+Time.now.to_i.to_s
          sleep(1)
         invoice.invoice_status_id = 2
         invoice.cash_invoice = 1
         invoice.cash_customer_name = row[0]
         invoice.fin_year = year.name

          line_item = InvoiceLineItem.new()
          line_item.product_id = product.id
          line_item.quantity = 1
          line_item.unit_rate = row[6].to_f
          line_item.amount = row[6].to_f
          line_item.type = "InvoiceLineItem"
          
          sales_warehouse_detail = SalesWarehouseDetail.new(:warehouse_id => warehouse.id, :quantity => 1)
          line_item.sales_warehouse_details << sales_warehouse_detail
          invoice.invoice_line_items << line_item
          
        if invoice.save_with_ledgers
           invoice.invoice_line_items.each do |line_item|
              if line_item.inventoriable? && company.plan.is_inventoriable?
                product = line_item.product
                line_item.sales_warehouse_details.each do |swd|
                  Stock.reduce(company.id, product.id, swd.warehouse_id, line_item.quantity)
                end
              end
            end 
        end
          success += 1
        else
          fail += 1
        end
        
         count += 1
        puts"@@@cash_customer_name:#{row[0]}, record_date : #{row[1]}, due_date:#{row[1]}, order_no:#{row[2]}, unit_rate: #{row[6]} " 
     end
  end
end
puts"invoices inserted successfully"
end 

end
