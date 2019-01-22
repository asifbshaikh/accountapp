namespace :estimate do 
  desc "migrating tax to double tax"
  task :migrate_into_double_tax => :environment do
    estimate_line_items = EstimateLineItem.where("tax_account_id is not null")
    index=0
    estimate_line_items.each do |line_item|
      if line_item.estimate_taxes.blank? 
        line_item.estimate_taxes<<EstimateTax.new(:account_id=>line_item.tax_account_id)
        index+=1
      end
      print"Updating #{index} out of #{estimate_line_items.count}\r"
    end
    print"#{index} records updated out of #{estimate_line_items.count}"
    puts
  end
  task :update_total_amount => :environment do
    @estimates = Estimate.all
    @estimates.each do |estimate|
      puts "estimate.amount #{estimate.amount}"
      estimate.update_attribute(:total_amount, estimate.amount)
    end
  end

  task :create_sequence => :environment do 
  	companies  = Company.all
  	puts"Adding estimate number sequence..."
  	i=0
  	companies.each do |company|
  		if EstimateSequence.create!(:company_id=> company.id)
	  		i+=1
	  	end
  	end
  	puts"Sequence for #{i} out of #{companies.count} companies has been added."
  end

  task :customize_voucher_number => :environment do 
    ActiveRecord::Base.transaction do 
      company = Company.find(1136)
      estimates = Estimate.where(:company_id=>company.id)
      voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(company.id, 1)
      estimate_sequence = EstimateSequence.find_by_company_id(company.id)

      voucher_setting.update_attributes!(:voucher_number_strategy=>1, :prefix=>"13-14/GCS/QUOTE")
      estimate_sequence.update_attribute('estimate_sequence', 0)
      estimates.each do |estimate|
        estimate.update_attribute('estimate_number', VoucherSetting.next_estimate_number(company))
      end
    end
  end
end