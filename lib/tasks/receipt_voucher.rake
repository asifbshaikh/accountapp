namespace :receipt_voucher do
	
	desc "To refresh foreign currency"
	task :refresh => :environment do
		receipt_vouchers = ReceiptVoucher.where("currency_id is not null and exchange_rate is not null and exchange_rate > 0")
		i=0
		receipt_vouchers.each do |receipt_voucher|
			receipt_voucher.update_and_post_ledgers
			i+=1
			print"#{i} receipts updated out of #{receipt_vouchers.count}\r"
		end
		puts"#{i} receipts updated out of #{receipt_vouchers.count}"
	end

	task :create_sequence => :environment do 
		ActiveRecord::Base.transaction do 
			companies = Company.all
			puts"Creating sequence number for all companies..."
			i=0
			companies.each do |company|
				if ReceiptVoucherSequence.create!(:company_id=>company.id)
					i+=1
				end
			end
			puts"Sequence number generated for #{i} out of #{companies.count} companies"
		end
	end	

	desc "many to many relation of receipt_vouchers and invoices"
		task :change_association_with_invoices => :environment do
		ActiveRecord::Base.transaction do 
			invoices = Invoice.all
			invoices.each do |invoice|
				receipt_vouchers = ReceiptVoucher.where(:invoice_id=>invoice.id, :deleted=>false)
				receipt_vouchers.each do |receipt_voucher|
					invoice_receipt=InvoicesReceipt.new(:amount=>receipt_voucher.amount, :tds_amount=>receipt_voucher.tds_amount)
					invoice.invoices_receipts<<invoice_receipt
					receipt_voucher.invoices_receipts<<invoice_receipt
				end
			end
		end
	end
end