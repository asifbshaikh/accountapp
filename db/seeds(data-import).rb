require 'rubygems'
require 'csv'
require 'country'

@environment = 'production'
@dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection @dbconfig[@environment]
# 1) Data uploaded for Abhay corporation
# csv = CSV.read("#{Rails.root}/abhaycorp1.csv")
# puts"csv.first = #{csv.first.class}"
# success = 0
# fail = 0
# count = 0
# csv.each do |row|
# if csv.first == row
#   puts"@@@ first csv row is #{csv.first == row}"
# else
#     company = Company.find_by_id(824)
#     user = company.users.first
#     expense_account = Account.find_by_name_and_company_id("Purchase Account - default expense", company.id)
#     income_account = Account.find_by_name_and_company_id("Sales Account - default income", company.id)
#     if !row.blank? && !expense_account.blank?
#       product = Product.new(:name => row[0], :reorder_level => row[1], :description => row[2], :unit_of_measure => row[3], :purchase_price=> row[4])
#       product.company_id = company.id
#       product.created_by = user.id
#       product.inventory = 1
#       product.type = "PurchaseItem"
#       product.expense_account_id = expense_account.id
#       product.save!
#      success += 1
#     else
#      fail += 1
#    end
#    count += 1
#  end
# end
# puts"#{success} inserted and #{fail} fails amongs #{count} items"

# csv = CSV.read("#{Rails.root}/abhaycorp2.csv")
# puts"csv.first = #{csv.first.class}"
# success = 0
# fail = 0
# count = 0
# csv.each do |row|
# if csv.first == row
#   puts"@@@ first csv row is #{csv.first == row}"
# else
#     company = Company.find_by_id(824)
#     user = company.users.first
#     expense_account = Account.find_by_name_and_company_id("Purchase Account - default expense", company.id)
#     income_account = Account.find_by_name_and_company_id("Sales Account - default income", company.id)
#      if !row.blank? && !expense_account.blank? && !income_account.blank?
#        product = Product.new(:name => row[0], :reorder_level => row[1], :description => row[2], :unit_of_measure => row[3], :purchase_price=> row[4],:sales_price => row[5])
#        product.company_id = company.id
#        product.created_by = user.id
#        product.inventory = 1
#        product.type = "ResellerItem"
#        product.expense_account_id = expense_account.id
#        product.income_account_id = income_account.id
#        product.save!
#       success += 1
#      else
#       fail += 1
#     end
#     count += 1
#    # puts"@@@ name : #{row[0]}, reo_l:#{row[1]}, des:#{row[2]}, uom: #{row[3]},purchase price : #{row[4]}, sales_price:#{row[5]} "
#  end
# end
# puts"#{success} inserted and #{fail} fails amongs #{count} items"

# 2)Data for Neelam enterprises
# a) product with retailer price
# csv = CSV.read("#{Rails.root}/Neelament1.csv")
# puts"csv.first = #{csv.first.class}"
# success = 0
# fail = 0
# count = 0
# csv.each do |row|
# if csv.first == row
#   puts"@@@ first csv row is #{csv.first == row}"
# else
#     company = Company.find_by_id(770)
#     user = company.users.first
#     expense_account = Account.find_by_name_and_company_id("Purchase Account - default expense", company.id)
#     income_account = Account.find_by_name_and_company_id("Sales Account - default income", company.id)
#      if !row.blank? && !expense_account.blank? && !income_account.blank?
#        product = Product.new(:name => row[0], :reorder_level => row[1], :description => row[2], :unit_of_measure => row[3], :purchase_price=> row[4],:sales_price => row[5])
#        product.company_id = company.id
#        product.created_by = user.id
#        product.inventory = 1
#        product.type = "ResellerItem"
#        product.expense_account_id = expense_account.id
#        product.income_account_id = income_account.id
#        product.save!
#       success += 1
#      else
#       fail += 1
#     end
#      count += 1
#     puts"@@@ name : #{row[0]}, reo_l:#{row[1]}, des:#{row[2]}, uom: #{row[3]}, purchase_price:#{row[4]}, sale_price : #{row[5]} "
#  end
# end
# puts"#{success} inserted and #{fail} fails amongs #{count} items"

# loop1------------------------
# b) product with relience price
# csv = CSV.read("#{Rails.root}/Neelament.csv")
# puts"csv.first = #{csv.first.class}"
# success = 0
# fail = 0
# count = 0
# csv.each do |row|
# if csv.first == row
#   puts"@@@ first csv row is #{csv.first == row}"
# else
#     company = Company.find_by_id(770)
#     user = company.users.first
#     expense_account = Account.find_by_name_and_company_id("Purchase Account - default expense", company.id)
#     income_account = Account.find_by_name_and_company_id("Sales Account - default income", company.id)
#      if !row.blank? && !expense_account.blank? && !income_account.blank?
#        product = Product.new(:name => row[0], :reorder_level => row[1], :description => row[2], :unit_of_measure => row[3], :purchase_price=> row[4],:sales_price => row[5])
#        product.company_id = company.id
#        product.created_by = user.id
#        product.inventory = 1
#        product.type = "ResellerItem"
#        product.expense_account_id = expense_account.id
#        product.income_account_id = income_account.id
#        product.save!
#       success += 1
#      else
#       fail += 1
#     end
#      count += 1
#     puts"@@@ name : #{row[0]}, reo_l:#{row[1]}, des:#{row[2]}, uom: #{row[3]}, purchase_price:#{row[4]}, sale_price : #{row[5]} "
#  end
# end
# puts"#{success} inserted and #{fail} fails amongs #{count} items"

# loop2-------------------------------
# 3) Jodhpur surgicals data import 
csv = CSV.read("#{Rails.root}/Book1.csv")
puts"csv.first = #{csv.first.class}"
success = 0
fail = 0
count = 0
csv.each do |row|
if csv.first == row
  puts"@@@ first csv row is #{csv.first == row}"
else
     company = Company.find_by_id(859)
     user = company.users.first
     expense_account = Account.find_by_name_and_company_id("Purchase Account - default expense", company.id)
     income_account = Account.find_by_name_and_company_id("Sales Account - default income", company.id)
     if !row.blank? && !expense_account.blank? && !income_account.blank?
       product = Product.new(:name => row[0], :reorder_level => row[1], :description => row[2], :unit_of_measure => row[3], :purchase_price=> row[4],:sales_price => row[5])
       product.company_id = company.id
       product.created_by = user.id
       product.inventory = 1
       product.type = "ResellerItem"
       product.expense_account_id = expense_account.id
       product.income_account_id = income_account.id
       product.save!
      success += 1
     else
      fail += 1
    end
     count += 1
    puts"@@@ name : #{row[0]}, reo_l:#{row[1]}, des:#{row[2]}, uom: #{row[3]}, purchase_price:#{row[4]}, sale_price : #{row[5]} "
 end
end
puts"#{success} inserted and #{fail} fails amongs #{count} items"
