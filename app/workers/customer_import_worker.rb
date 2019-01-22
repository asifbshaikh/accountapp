class CustomerImportWorker
  include Sidekiq::Worker
  require 'date'
  require 'csv'
  require 'open-uri'

  STATUS = {fail: 0, success: 1}  

  # @queue = :customer_imports_queue. We currently have a common queue
  def perform(company_id, user_id, file_id)
    company = Company.find(company_id)
    user = User.find(user_id)
    imported_file = ImportFile.find(file_id)

    begin
      file = CSV.parse(open(imported_file.file.url).read)
      success_cnt=0
      failure_cnt=0
      #drop the header line
      file.drop(1).each do |line|
        customer_import_entry = CustomerImport.new_record(company, user, imported_file, line)
        customer = Customer.new_customer(company, user, customer_import_entry)
        if customer.save
          customer_import_entry.save_as_success
          success_cnt += 1
        else
          customer_import_entry.save_for_correction
          failure_cnt += 1
        end  
      end
      imported_file.processing_completed
    rescue StandardError => e
      puts "The error is #{e}"
      imported_file.processing_failed
    end  
  end

end