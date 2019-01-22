namespace :delivery_challan do 
  
  task :create_sequence => :environment do 
  	companies  = Company.all
  	puts"Adding delivery_challan number sequence..."
  	i=0
  	companies.each do |company|
      dl_seq = DeliveryChallanSequence.find_by_company_id(company.id)
      if dl_seq.blank?
  		if DeliveryChallanSequence.create!(:company_id=> company.id)
          puts"@@@ created dlseq for company #{company.name} "
	  		i+=1
	  	end
    else
      puts"@@@ company #{company.name} has right record"
    end
  	end
  	puts"Sequence for #{i} out of #{companies.count} companies has been added."
  end

  task :update_delivery_challan => :environment do
    Company.all.each do |company|
    delivery_challans = company.delivery_challans.where("customer_id is null")
    puts"@@@company #{company.name} has #{delivery_challans.count} DC"
     delivery_challans.each do |dc|
       if !dc.account_id.blank?
        customer = dc.account.customer.blank? ? dc.account.vendor : dc.account.customer
         dc.update_attribute("customer_id", customer.id)
         puts "dc updated successfully with id #{dc.id} and customer id #{dc.customer_id}"
       else
         puts "dc account id is blank"
       end
     end
    end
  end
  
  
end