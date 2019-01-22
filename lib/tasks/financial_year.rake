namespace :financial_year do
	desc "changing financial year"
	task :change => :environment do
		ActiveRecord::Base.transaction do
		  year=Year.find_by_name("FY16")
		  i=0
			# year=Year.find_by_name('FY15')
			# financial_years = FinancialYear.where("start_date like '%-04-01' and start_date!='2015-04-01' ")
			companies= Company.includes(:financial_years).where("financial_years.start_date like '%-08-01' and financial_years.start_date!='2015-08-01' ")
			companies.each do |company|
				financial_year=FinancialYear.new(:year_id=>year.id, :start_date=>'2015-08-01', :end_date=>'2016-07-31')
				company.financial_years<<financial_year
				i+=1
				print"#{i} new financial_years has been added out of #{companies.count}\r"
			end
			puts"#{i} new financial_years has been added out of #{companies.count}"
		end
	end


	desc "create a new financial year entry by CRON. This task should run before mid night of every day. Ideally at 11:00 PM for days like 31-Mar when lot of companies FY ends"
	task :create_financial_year => :environment do
		#select all companies whose latest financial year end date is < current date
		print "Time zone Date is #{Time.zone.now.to_date}"
		companies = Company.includes(:financial_years).where("financial_years.end_date = ?", Time.zone.now.to_date)
		#print "-----------companies selected #{companies.inspect}"
		companies.each do |company|
			#print "The eligible companies are #{company.inspect}"
			print " Latest financial_year #{company.id} , #{company.name}, #{company.financial_years.last.end_date}, #{company.financial_years.last.start_date}, #{company.financial_years.last.end_date}, #{company.financial_years.last.year.name} \n"
			new_start_date = company.financial_years.last.start_date + 1.years
			new_end_date = company.financial_years.last.end_date + 1.years
			print " New start date #{new_start_date}, New End date #{new_end_date}  \n"
			#code to determine the Year ID e.g. FY16 or FY17
			end_date_year = new_end_date.strftime('%y')
			print " New END Year #{end_date_year} \n"
			fin_year = "FY#{end_date_year}"
			new_year = Year.find_by_name(fin_year)
			print " The year retrieved is #{new_year.inspect}"
			#If the year is non existing i.e. on 31-Dec-XXXX of any year then
			if new_year.nil?
				new_year = Year.new(:name=> fin_year)
				new_year.save
			end
			new_fin_year = FinancialYear.new(:year_id => new_year.id, :start_date => new_start_date, :end_date => new_end_date)
			company.financial_years << new_fin_year
		end
	end
end
