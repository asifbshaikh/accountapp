namespace :payment_voucher do 
	task :create_sequence => :environment do 
		ActiveRecord::Base.transaction do 
			companies = Company.all
			i=0
			puts"Creating sequences for all companies..."
			companies.each do |company|
				if PaymentVoucherSequence.create!(:company_id=> company.id)
					i+=1
				end
			end
			puts"Sequences for #{i} out of #{companies.count} companies has been created"
		end
	end

	desc "many to many relation of payment_vouchers and purchases"
		task :change_association_with_purchases => :environment do
		ActiveRecord::Base.transaction do 
			payment_vouchers = PaymentVoucher.all
			i=0
			payment_vouchers.each do |payment_voucher|
				purchase = Purchase.find_by_id(payment_voucher.purchase_id)
				unless purchase.blank?
					purchase_payment=PurchasesPayment.new(:payment_voucher_id=> payment_voucher.id, :amount=>payment_voucher.amount, :tds_amount=>payment_voucher.tds_amount)
					purchase.purchases_payments<<purchase_payment
				end
				i+=1
				print"#{i} payments updated out of #{payment_vouchers.count}\r"
			end
			puts"#{i} payments updated out of #{payment_vouchers.count}"
		end
	end

	desc "many to many relation of payment_vouchers and expenses"
		task :change_association_with_expenses => :environment do
		ActiveRecord::Base.transaction do 
			payment_vouchers = PaymentVoucher.where("expense_id is not null")
			i=0
			payment_vouchers.each do |payment_voucher|
				expense = Expense.find_by_id(payment_voucher.expense_id)
				unless expense.blank?
					expense_payment=ExpensesPayment.new(:payment_voucher_id=> payment_voucher.id, :amount=>payment_voucher.amount, :tds_amount=>payment_voucher.tds_amount)
					expense.expenses_payments<<expense_payment
				end
				i+=1
				print"#{i} payments updated out of #{payment_vouchers.count}\r"
			end
			puts"#{i} payments updated out of #{payment_vouchers.count}"
		end
	end

	desc "find and convert to other payments"
		task :find_and_convert_other_payment => :environment do
		ActiveRecord::Base.transaction do 
			payment_vouchers = PaymentVoucher.where("expense_id is null and purchase_id is null")
			i=0
			payment_vouchers.each do |payment_voucher|
				if payment_voucher.purchases_payments.blank? && payment_voucher.expenses_payments.blank?
					payment_voucher.update_attribute("voucher_type", 2)
					i+=1
				end
				print"#{i} payments out of #{payment_vouchers.count} converted to other payment\r"
			end
			puts"#{i} payments out of #{payment_vouchers.count} converted to other payment"
		end
	end
end	
# purchases = Purchase.all
# i=0
# # j=0
# # k=0
# # l=0
# purchases.each do |purchase|
# 	payment_vouchers = PaymentVoucher.where(:purchase_id=>purchase.id, :deleted=>false)
# 	payment_vouchers.each do |payment_voucher|
# 		if purchase.purchases_payments.blank? 
# 			purchase_payment=PurchasesPayment.new(:payment_voucher_id=> payment_voucher.id, :amount=>payment_voucher.amount, :tds_amount=>payment_voucher.tds_amount)
# 			purchase.purchases_payments<<purchase_payment
# 		end
# 	end
# 	i+=1
# 	print"#{i} purchases updated out of #{purchases.count}\r"
# end
# puts"#{i} purchases updated out of #{purchases.count}"
# # payment_vouchers=PaymentVoucher.all
# # payment_vouchers.each do |payment_voucher|
# # 	unless ["SundryDebtor", "SundryCreditor"].include?(payment_voucher.to_account.accountable_type)
# # 		if payment_voucher.purchases_payments.blank?

# # 			j+=1
# # 		else
# # 			k+=1
# # 		end
# # 	end
# # 	print"#{j} payments out of #{payment_vouchers.count} are marked as other as they are not aginst vendor and #{k} payments are aginst purchase voucher but paid to other than vendor account"
# # end