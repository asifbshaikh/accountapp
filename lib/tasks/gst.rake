namespace :gst do 
  task :create_taxes => :environment do   
    error_companies = Array.new
    valid_plans = Plan.where(:name=>['SMB','Professional','Trial','Enterprise']) 
    puts " valid plans #{valid_plans.inspect}"
    valid_plans.each do |plan|
      plan.companies.each do |company|
        if company.active? && company.currency_code == 'INR'
          user = company.users.first
          begin
            ActiveRecord::Base.transaction do 
              Account.create_gst_accounts(company, user)
            end
            puts "Plan is #{plan.name} and company is #{company.id} , #{company.name}"
          rescue Exception => e
            puts e
            error_companies.push(company)
          end
        end    
      end
    end
    error_companies.each {|company| puts "#{company.id} and #{company.name}" }
  end

  #created gst accounts for companies given in the array
  task :create_gst_taxes_for_company => :environment do   
    error_companies = Array.new
    companies = [16396, 16397, 8663]
    companies.each do |company_id|
      company = Company.find(company_id)
      if company.active? && company.currency_code == 'INR'
        user = company.users.first
        begin
          ActiveRecord::Base.transaction do 
            Account.create_gst_accounts(company, user)
          end
          puts "company is #{company.id} , #{company.name}"
        rescue Exception => e
          puts e
          error_companies.push(company)
        end
      end    
    end
    error_companies.each {|company| puts "#{company.id} and #{company.name}" }
  end

  #created gst accounts for companies given in the array
  task :create_3percent_taxes_for_company => :environment do   
    gst_rates = ['3%']
    gst_rate_percentages = [3]
    gst_tax_types = ['GST', 'IGST']
    gst_taxes_on = ['sales', 'purchases']
    gst_child_taxes = ['CGST', 'SGST']
    filling_frequency = 1
    error_companies = Array.new
    companies = [16397]
    companies.each do |company_id|
      company = Company.find(company_id)
      account_head = AccountHead.find_by_company_id_and_name(company, "Duties and Taxes")
      start_date = '2017-07-01'
      if company.active? && company.currency_code == 'INR'
        user = company.users.first
        begin
          ActiveRecord::Base.transaction do
            gst_rates.each_with_index do |gst_rate, gst_rate_index|

              gst_tax_types.each_with_index do |gst_tax_type, gst_tax_type_index|
                gst_taxes_on.each do |tax_on|
                  if tax_on == 'sales'
                    apply_to=1
                  else
                    apply_to=2
                  end
                  if (gst_tax_type == "GST") && (gst_rate_percentages[gst_rate_index] != 0)
                    #create parent GST @tax rate
                    gst_account = Account.new(:name=> "#{gst_tax_type} @#{gst_rate} on #{tax_on}",
                      :company_id => company.id, :account_head_id => account_head.id, :opening_balance => 0,
                      :created_by => user.id, :start_date => start_date )
                    gst_account.accountable = DutiesAndTaxesAccounts.new(:apply_to => apply_to,
                      :description => 'The Goods and Service Tax', :tax_rate => gst_rate_percentages[gst_rate_index], 
                      :filling_frequency => filling_frequency, :calculate_on_percent=> 100,
                      :calculation_method=> 4, :split_tax => 0) # calculation method 4 - means split tax, tax is split in child taxes
                    #puts "The GST account to be saved is #{gst_account.inspect}"
                    gst_account.save!  
                    #create child CGST@tax_rate/2
                    gst_child_taxes.each do |gst_child_tax|
                      linked_child_account = Account.new(:name=> "#{gst_child_tax} @#{gst_rate_percentages[gst_rate_index].to_d/2} on #{tax_on}",
                        :company_id => company.id,
                        :account_head_id => account_head.id, :opening_balance => 0,
                        :created_by => user.id, :start_date => start_date,
                        :parent_id => gst_account.id)
                      linked_child_account.accountable = DutiesAndTaxesAccounts.new(:apply_to => apply_to,
                        :description => 'The Goods and Service Tax', :tax_rate => 50, 
                        :filling_frequency => filling_frequency, :calculate_on_percent=> 100,
                        :calculation_method=> 1, :split_tax=>1)
                      #puts "The GST linked child account to be saved is #{linked_child_account.inspect}"
                      linked_child_account.save!
                    end #loop for child taxes
                  else
                    #create single IGST @tax rate
                    gst_account = Account.new(:name=> "#{gst_tax_type} @#{gst_rate} on #{tax_on}",
                      :company_id => company.id,
                      :account_head_id => account_head.id, :opening_balance => 0,
                      :created_by => user.id, :start_date => start_date )
                    gst_account.accountable = DutiesAndTaxesAccounts.new(:apply_to => apply_to,
                      :description => 'The Goods and Service Tax', :tax_rate => gst_rate_percentages[gst_rate_index], 
                      :filling_frequency => filling_frequency, :calculate_on_percent=> 100,
                      :calculation_method=> 3) # calculation method 4 - means split tax, tax is split in child taxes
                    #puts "The IGST account to be saved is #{gst_account.inspect}"
                    gst_account.save!  
                  end
                end #loop end for gst_purchase_sales  
              end #loop end for  gst_tax_type
            end#loop end for gst_rate  
          end
          puts "company is #{company.id} , #{company.name}"
        rescue Exception => e
          puts e
          error_companies.push(company)
        end
      end    
    end
    error_companies.each {|company| puts "#{company.id} and #{company.name}" }    
  end



  #desciptions take job to add GST company categories
  task :create_category => :environment do
    puts "start creating the categories"
    category_names = ['Registered', 'Unregistered','Composition Scheme','Input Service Distributor','E-Commerce Operator']
    category_description = ['Have GSTIN','Do not have GST registration','Having turnover below INR 75 lakhs and registered as composite dealer','Registered as ISD','Selling online Goods']
    category_names.each_with_index do |category, index|
      category = GstCategory.new(:name=> category, :description => category_description[index])
      category.save!
    end
  end

  task :create_gstr3b => :environment do   
    error_companies = Array.new
    valid_plans = Plan.where(:name=>['SMB','Professional','Trial','Enterprise']) 
    puts " valid plans #{valid_plans.inspect}"
    valid_plans.each do |plan|
      plan.companies.each do |company|
        if company.active? && company.currency_code == 'INR'
          user = company.users.first
          next if company.GSTIN.blank?
          begin
            fin_year = company.financial_years.last
            ActiveRecord::Base.transaction do 
              Gstr3bReport.create!(:company_id => company.id, :financial_year_id => fin_year.id, :month => 9, :name => company.name, :status => 0, :gstin => company.GSTIN)
              Gstr3bReport.create!(:company_id => company.id, :financial_year_id => fin_year.id, :month => 10, :name => company.name, :status => 0, :gstin => company.GSTIN)

            end
            puts "Plan is #{plan.name} and company is #{company.id} , #{company.name}"
          rescue Exception => e
            puts e
            error_companies.push(company)
          end
        end    
      end
    end
    error_companies.each {|company| puts "#{company.id} and #{company.name}" }    
  end

  task :create_gstr3b_for_company => :environment do   
    error_companies = Array.new
    company = Company.find(24711)

      if company.currency_code == 'INR'
        puts "Company is Indian"
        user = company.users.first
        next if company.GSTIN.blank?
        begin
          fin_year = company.financial_years.last
          ActiveRecord::Base.transaction do 
            Gstr3bReport.create!(:company_id => company.id, :financial_year_id => fin_year.id, :month => 7, :name => company.name, :status => 0, :gstin => company.GSTIN)
            Gstr3bReport.create!(:company_id => company.id, :financial_year_id => fin_year.id, :month => 8, :name => company.name, :status => 0, :gstin => company.GSTIN)

          end
          puts "Plan is #{company.plan.name} and company is #{company.id} , #{company.name}"
        rescue Exception => e
          puts e
          error_companies.push(company)
        end
      end    
    error_companies.each {|company| puts "#{company.id} and #{company.name}" }    
  end


end  
