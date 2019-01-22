#This is a Sidekiq worker added for generating gstr_advance_receipt details for gstr1 filing .
#assigning gstr_advance_receipt classiifier for further process
#Author: Rohit Chandran
#Date: 25-07-2017 

class GstrAdvanceReceiptFilerWorker 
  include Sidekiq::Worker

  # @queue = :product_imports_queue
  def perform(company_id, gstr_advance_receipt_id)

    @company = Company.find(company_id)
    @gstr_advance_receipt = @company.gstr_advance_receipts.find(gstr_advance_receipt_id)

    begin 
      #Sidekiq.logger.debug "gstr_advance_receiptFilerWorker::perform::begin for gstr_advance_receipt #{@gstr_advance_receipt.inspect}"
      #determine gstr_advance_receipt date so we know which gstr1 we need to add this item
      gstr_advance_receipt_month = @gstr_advance_receipt.voucher_date.month
      @gst_returns = @company.gst_returns.return_month(gstr_advance_receipt_month)
      if @gst_returns.present? && @gst_returns.gstr_one.present?
        @gst_returns.gstr_one.add_gstr_advance_receipt(@gstr_advance_receipt)
      end
    rescue Exception => e
      Sidekiq.logger.error e
      #ErrorMailer.experror(e, @company.users.first, "gstr_advance_receiptFilerWorker for gstr_advance_receipt #{@gstr_advance_receipt.id} and #{@gstr_advance_receipt.gstr_advance_receipt_number}").deliver
      #raise e
    end     
  end
end
