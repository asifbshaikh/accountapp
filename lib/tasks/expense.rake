namespace :expense do 
	desc "migrating tax to double tax"
	task :migrate_into_double_tax => :environment do
	  expense_line_items = ExpenseLineItem.where(:type=>nil, :tax=>1)
	  index=0
	  expense_line_items.each do |line_item|
	    if line_item.expense_taxes.blank?
	      line_item.expense_taxes<<ExpenseTax.new(:account_id=>line_item.account_id)
	      index+=1
	    end
	    print"Updating #{index} out of #{expense_line_items.count}\r"
	  end
	  print"#{index} records updated out of #{expense_line_items.count}"
	  puts
	end

	task :create_sequence => :environment do 
		ActiveRecord::Base.transaction do 
			companies = Company.all 
			i=0
			puts"Creating sequenses for all companies..."

			companies.each do |company|
				if ExpenseSequence.create!(:company_id=> company.id)
					i+=1
				end
			end
			puts"Sequences for #{i} out of #{companies.count} companies has been created"
		end
	end 		
end