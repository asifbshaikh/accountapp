#Rake tasks for creating GSTR returns for companies
#Naveen 20 Aug 2017
namespace :gstr do 
  #This task will create the GST returns for all companies for the next 3 months if not already present
  #This task will take care of the returns to be generated based on the company registration type?
  #If present this will ignore them
  #This task will run on 25 of every month
  task :create_gst_returns_entries => :environment do
    current_month = Time.zone.now.to_date.month
    puts "The current date is #{Time.zone.now.to_date}"
    puts "The current month is #{current_month}"
    months = [7, 8, 9, 10]
    one_date = ["2017-09-05", "2017-09-20", "2017-10-10" , "2017-11-10" ] 
    two_date = ["2017-09-25", "2017-10-10", "2017-10-10" , "2017-11-10"]
    error_companies = Array.new
    valid_plans = Plan.where(:name=>['SMB','Professional','Trial','Enterprise']) 
    valid_plans.each do |plan|
      @companies = plan.companies.where("GSTIN is not null and gst_category_id is NOT NULL")
      @companies.each do |company|
        if company.active? && company.currency_code == 'INR'
          @return_types = company.gst_category.gst_return_types
          begin        
            months.each_with_index do |month, index|
              gst_return = GstReturn.create_return(company, month)
              gstr_one = GstrOne.create_return(company, gst_return, one_date[index])
              gstr_two = GstrTwo.create_return(company, gst_return, two_date[index])
              gstr2a = Gstr2a.create_return(company, gst_return, two_date[index])
              puts "GST returns created for company #{company.name} for month #{Date::MONTHNAMES[month]}"
            end
          rescue Exception => e

            puts "failed for company #{company.id} #{company.name} due to #{e.message}"
            next
          end  
        end
      end
    end
    error_companies.each {|company| puts "#{company.id} and #{company.name}" }    
  end

  task :create_gstr1_entries => :environment do
    valid_plans = Plan.where(:name=>['SMB','Professional','Trial','Enterprise']) 
    valid_plans.each do |plan|
      @companies = plan.companies.where("GSTIN is not null and gst_category_id is NOT NULL")
      @companies.each do |company|
        begin
          invoices = company.invoices.where(:gst_invoice => true)
          invoices.each do |invoice| 
            InvoiceFilerWorker.perform_async(company.id, invoice.id)
            puts "Task completed for company #{company.id} and invoice #{invoice.invoice_number}"
          end
          puts "=================#{company.id}==============="
        rescue
          puts "failed for  company #{company.id}"
          next
        end
      end
    end  
  end


  task :create_gstr2_entries => :environment do
    valid_plans = Plan.where(:name=>['SMB','Professional','Trial','Enterprise']) 
    valid_plans.each do |plan|
      @companies = plan.companies.where("GSTIN is not null and gst_category_id is NOT NULL")
      @companies.each do |company|
        begin
          purchases = company.purchases.where(:gst_purchase => true).where("record_date >='2017-07-01'")
          purchases.each do |purchase| 
            PurchaseFilerWorker.perform_async(company.id, purchase.id)
            puts "Task completed for company #{company.id} and purchase #{purchase.purchase_number}"
          end
          puts "=================#{company.id}==============="
        rescue
          puts "failed for  company #{company.id}"
          next
        end
      end
    end  
  end

task :create_gstr2_expense_entries => :environment do
    valid_plans = Plan.where(:name=>['SMB','Professional','Trial','Enterprise']) 
    valid_plans.each do |plan|
      @companies = plan.companies.where("GSTIN is not null and gst_category_id is NOT NULL")
      @companies.each do |company|
        begin
          expenses = company.expenses.where(:gst_expense => true).where("expense_date >='2017-07-01'")
          expenses.each do |expense| 
            ExpenseFilerWorker.perform_async(company.id,expense.id)
            puts "Task completed for company #{company.id} and expense #{expense.id}"
          end
          puts "=================#{company.id}==============="
        rescue
          puts "failed for  company #{company.id}"
          next
        end
      end
    end  
  end



 task :create_gstr2_expense_for_company => :environment do
    @companies = [9110]
    @companies.each do |company_id|
      begin
        company = Company.find(company_id)
        expenses = company.expenses.where(:gst_expense => true).where("expense_date >='2017-07-01'")
          expenses.each do |expense|
           ExpenseFilerWorker.perform_async(company.id,expense.id)
            puts "Task completed for company #{company.id} and expense #{expense.id}"
          end
        puts "=================#{company.id}==============="
      rescue
        puts "failed for  company #{company.id}"
        next
      end
    end
  end  



  task :create_gstr2_entries_for_company => :environment do
    @companies = [7063]
    @companies.each do |company_id|
      begin
        company = Company.find(company_id)
         purchases = company.purchases.where(:gst_purchase => true).where("record_date >='2017-07-01'")
      purchases.each do |purchase| 
            PurchaseFilerWorker.perform_async(company.id, purchase.id)
            puts "Task completed for company #{company.id} and purchase #{purchase.purchase_number}"
          end
        puts "=================#{company.id}==============="
      rescue
        puts "failed for  company #{company.id}"
        next
      end
    end
  end  


  task :create_gstr1_entries_for_company => :environment do
    @companies = [7063]
    @companies.each do |company_id|
      begin
        company = Company.find(company_id)
        invoices = company.invoices.where(:gst_invoice => true)
        invoices.each do |invoice| 
          InvoiceFilerWorker.perform_async(company.id, invoice.id)
          puts "Task completed for company #{company.id} and invoice #{invoice.invoice_number}"
        end
        puts "=================#{company.id}==============="
      rescue
        puts "failed for  company #{company.id}"
        next
      end
    end
  end  

end
