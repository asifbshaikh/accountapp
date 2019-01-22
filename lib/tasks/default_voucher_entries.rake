namespace :DefaultVoucherEntries do 
	task :create_entries=> :environment do 
		ActiveRecord::Base.transaction do 
			 #voucher settings for GST debit note,credit note and advance receipt
		   @companies = Company.all
		   # @voucher_settings = VoucherSetting.all
		   @companies.each do |company|
			   	debit_voucher_setting = VoucherSetting.new
			   	debit_voucher_setting.voucher_type = 28
			   	debit_voucher_setting.company_id = company.id
			   	debit_voucher_setting.voucher_number_strategy = 1
			   	debit_voucher_setting.save!

			   	debit_voucher_sequences = GstDebitNoteSequence.new
			   	debit_voucher_sequences.company_id = company.id
			   	debit_voucher_sequences.gst_debit_note_sequence = 0
			   	debit_voucher_sequences.save!

		        ar_voucher_setting = VoucherSetting.new
		        ar_voucher_setting.voucher_number_strategy = 1
		        ar_voucher_setting.company_id = company.id
		        ar_voucher_setting.voucher_type = 25
		        ar_voucher_setting.save!

		        ar_voucher_sequences = GstrAdvanceReceiptVoucherSequence.new
		        ar_voucher_sequences.company_id = company.id
		        ar_voucher_sequences.gstr_advance_receipt_voucher_sequence = 0
		        ar_voucher_sequences.save!
		    

		        ap_voucher_setting = VoucherSetting.new
		        ap_voucher_setting.voucher_number_strategy = 1
		        ap_voucher_setting.company_id = company.id
		        ap_voucher_setting.voucher_type = 26
		        ap_voucher_setting.save!

		        ap_voucher_sequences = GstrAdvancePaymentVoucherSequence.new
		        ap_voucher_sequences.company_id = company.id
		        ap_voucher_sequences.gstr_advance_payment_voucher_sequence = 0
		        ap_voucher_sequences.save!
		    
		        credit_voucher_setting = VoucherSetting.new
		        credit_voucher_setting.voucher_number_strategy = 1
		        credit_voucher_setting.company_id = company.id
		        credit_voucher_setting.voucher_type = 27
		        credit_voucher_setting.save!

		        credit_voucher_sequence = GstCreditNoteSequence.new
		        credit_voucher_sequence.company_id = company.id
		        credit_voucher_sequence.gst_credit_note_sequence = 0
		        credit_voucher_sequence.save!

		         puts "Voucher entries created #{company.name}"

		     end

		end
	end
end