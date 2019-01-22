namespace :reimbursement do
	task :note_number_strategy => :environment do
		ActiveRecord::Base.transaction do
		  company = Company.select(:id).all
		  company.each do |t|
		    VoucherSetting.create!(:company_id => t.id, :voucher_number_strategy => 1, :voucher_type => 23)
		    ReimbursementNoteSequence.create!(:company_id => t.id, :reimbursement_note_sequence => 1)
		  end
		end
	end 

	task :voucher_number_strategy => :environment do
		ActiveRecord::Base.transaction do
  			company = Company.select(:id).all
  			company.each do |t|
    			VoucherSetting.create!(:company_id => t.id, :voucher_number_strategy => 1, :voucher_type => 24)
    			ReimbursementVoucherSequence.create!(:company_id => t.id, :reimbursement_voucher_sequence => 1)
  			end
		end
	end
end

