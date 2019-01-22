namespace :customer_relationship do 
	task :add_company_id => :environment do 
		ActiveRecord::Base.transaction do 
			customer_relationship = CustomerRelationship.where(:notable_type => "Company")

			customer_relationship.each do |customer|
			customer.update_attributes(:company_id => customer.notable_id)
			puts"company_id added"
			end
		end	
	end

  task :change_activity => :environment do
    ActiveRecord::Base.transaction do
      companies = Company.all
      companies.each do |company|
        if company.subscription.status == "Paid"
          customer_relationships = company.customer_relationships
          activity = 1
          i = 0
          new_activity = [17,17,9,8,10,11,14,16,9,10,11,12,14,15,9,11,13,14,14,14]
          while i < 20
            customer_relationship = customer_relationships.where(:activity => activity)
            next_activity = customer_relationships.where(:next_activity => activity)
            customer_relationship.update_all(:activity =>new_activity[i])
            next_activity.update_all(:next_activity => new_activity[i])
            activity += 1
            i += 1
          end
          puts"***********Paid Company"
        else
          customer_relationships = company.customer_relationships
          activity = 1
          i = 0
          new_activity = [7,7,1,2,4,4,5,6,1,4,4,4,7,5,1,4,4,5,5,7]
          while i < 20
            customer_relationship = customer_relationships.where(:activity => activity)
            next_activity = customer_relationships.where(:next_activity => activity)
            customer_relationship.update_all(:activity =>new_activity[i])
            next_activity.update_all(:next_activity => new_activity[i])
            activity += 1
            i += 1
          end
          puts"***********Trial Company"
        end
      end
    end
  end

  task :add_completed_date => :environment do 
    ActiveRecord::Base.transaction do 
      customer_relationships = CustomerRelationship.where(:activity_status => true)
      count = 0
      customer_relationships.each do |customer_relationship|
      customer_relationship.update_attributes!(:completed_date => customer_relationship.updated_at.to_date)
      count += 1
      puts"Adding..."
      end
      puts"*************Total #{count} date added"
    end 
  end

end