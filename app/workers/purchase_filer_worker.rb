
#This is a Sidekiq worker added for generating invoice details for gstr1 filing .
#assigning invoice classiifier for further process
#Author: Rohit Chandran
#Date: 25-07-2017 

class PurchaseFilerWorker 
  include Sidekiq::Worker

  # @queue = :product_imports_queue
  def perform(company_id, purchase_id)
    #[FIXME] Move the find method to the new Model GST_item
    #first check if this invoice is for a new reporting month
    # if yes then entry in the gstr_two table is already present
    # if not then create entry for the new month
    @company = Company.find(company_id)
    @purchase = @company.purchases.find(purchase_id)

    begin 
      #determine invoice date so we know which gstr2 we need to add this item
      purchase_month = @purchase.record_date.month
      @gst_returns = @company.gst_returns.return_month(purchase_month)
      Rails.logger.debug "PurchaseFilerWorker::perform:: The gst_returns is #{@gst_returns.inspect}============="
      if @gst_returns.present? && @gst_returns.gstr_two.present?
        @gst_returns.gstr_two.add_purchase(@purchase)
      end  
    rescue Exception => e
      puts e
      Rails.logger.error e
      #ErrorMailer.experror(e, @company.users.first, "PurchaseFilerWorker").deliver
    end  
    #file_invoice.submit_for_processing(company_id,purchase_id)

    #check if this invoice update or insert
    #if update is it a already reported invoice or not reported invoice
    #if reported invoice it needs to be discarded. Ideally it should not have come to the worker
    #else proceed
    # classify the invoice according to the rules
    #insert/update into the gstr_two_item
     # begin
      
    # rescue Exception => e
       
    #     ErrorMailer.experror(e, user_id).deliver
    # end
   
  end





end
