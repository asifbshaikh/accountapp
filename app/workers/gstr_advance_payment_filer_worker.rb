class GstrAdvancePaymentFilerWorker 
  include Sidekiq::Worker
  def self.perform(company_id, gstr_advance_payment_id)
    @company = Company.find(company_id)
    @gstr_advance_payment = @company.gstr_advance_payments.find(gstr_advance_payment_id)
    Rails.logger.debug "gstadvpay #{@gstr_advance_payment.inspect}"

    begin 
      gstr_advance_payment_month = @gstr_advance_payment.date.month
      @gst_returns = @company.gst_returns.return_month(gstr_advance_payment_month)
      @gst_returns.gstr_two.add_gstr_advance_payment(@gstr_advance_payment)
    rescue Exception => e
      puts e
      Rails.logger.error e
    end  
  end

  def self.update_entries(company_id, gstr_advance_payment_id)
    @company = Company.find(company_id)
    @gstr_advance_payment = @company.gstr_advance_payments.find(gstr_advance_payment_id)
    begin 
      gstr_advance_payment_month = @gstr_advance_payment.date.month
      @gst_returns = @company.gst_returns.return_month(gstr_advance_payment_month)
      @gst_returns.gstr_two.update_gstr_advance_payment(@gstr_advance_payment)
    rescue Exception => e
      puts e
      Rails.logger.error e
    end
  end
end
