class WebhookController < ApplicationController
  layout :false
  skip_before_filter  :authorize_action, :authenticate, :check_messages, :check_if_allow, :company_active?, :mix_panel_track, :current_financial_year

	def payment_callback


    # message= params[:amount]+'|'+params[:buyer]+'|'+params[:buyer_name]+'|'+params[:buyer_phone]+'|'+ params[:currency]+'|'+ params[:fees]+'|'+params[:longurl]+'|'+params[:mac]+'|'+ params[:payment_id]+'|'+params[:payment_request_id]+'|'+params[:purpose]+'|'+params[:shorturl]+'|'+ params[:status]
    # puts "******************************"
    # puts message

    # mac_provided = params[:mac].to_s #mac_provided from Instamojo

    # salt_key='62f671501cb491d9c959f02459855932'#salt value obtained from instamojo which should be set on settings page, additional box to be created
    # puts Digest::HMAC.hexdigest(message,salt_key,Digest::SHA1)
    # mac_calculated= Digest::HMAC.hexdigest(message,salt_key,Digest::SHA1)

    # puts mac_provided
    # puts mac_calculated

    # if mac_provided == mac_calculated
		@request = InstamojoPaymentLink.find_by_payment_request_id(params[:payment_request_id])
		if @request
			     WebhookPayments.create_payment(params,request.remote_ip)
			     company= Company.find_by_id(@request.company_id)
		      	@fy_name= FinancialYear.find_by_company_id(company.id)
            @from_account = Account.find_by_id(@request.customer_id)
            @invoice=Invoice.find_by_id_and_company_id(@request.invoice_id,company.id)
            @current_user=User.find_by_id_and_company_id(@invoice.created_by,company.id)
            @to_account=InstamojoPayments.where(:company_id=>company.id).last
            @to_expense_account=Account.find_by_name_and_company_id("Payment Gateway Charges", company.id)
            @tax_account= Account.find_by_name_and_company_id("Service Tax @14% on purchase", company.id)
            @cess_account= Account.find_by_name_and_company_id("Cess @0.5% on purchase", company.id)

            
            @webhook_payments = WebhookPayments.create_receipt(params,company, @current_user, @fy_name.year.name,@from_account,@to_account,@request,@tax_account,@cess_account)
   			if @webhook_payments.valid?
   				    @webhook_payments.save_with_ledgers
       			  @webhook_payments.update_included_invoice_online_status
           		@webhook_payments.register_user_action(request.remote_ip, 'Received Instamojo online Payment')
            	@webhook_payments.create_online_payment_histories    
            end
            @expense = WebhookPayments.create_expense(params, company, @current_user,@fy_name.year.name,@from_account, @to_expense_account,@request,@tax_account,@cess_account)
            if @expense.valid?
              @expense.save_expense_with_ledgers(@to_expense_account,@tax_account,'instamojo')
              @expense.tax_line_items.each do |tax_line_item|
              @expense.expense_line_items.each do |line_item|
                logger.debug line_item.expense_taxes.inspect
                expense=ExpenseTax.new(:expense_line_item_id=>line_item.id, :account_id=>tax_line_item.account_id)
                expense.save!
              end
            end
              @expense.register_user_action(request.remote_ip, 'created for Instamojo online payment')
            end
		end

    # The webhook doesn't require a response but let's make sure
    # we don't send anything
      render :nothing => true
  # end	
	end


  def cashfree_callback

    @request = CashfreePaymentLink.find_by_order_id(params[:orderId])
    if @request
          CashfreeResponse.create_payment(params,request.remote_ip)
           company= Company.find_by_id(@request.company_id)
            @fy_name= FinancialYear.find_by_company_id(company.id)
            @from_account = Account.find_by_id(@request.customer_id)
            @invoice=Invoice.find_by_id_and_company_id(@request.invoice_id,company.id)
            @current_user=User.find_by_id_and_company_id(@invoice.created_by,company.id)
            @to_account=CashFreeSetting.where(:company_id=>company.id).last
            @to_expense_account=Account.find_by_id_and_company_id(@to_account.expense_account, company.id)
            @tax_account= Account.find_by_id_and_company_id(@to_account.expense_tax_account, company.id)
      if params[:txStatus].to_s == 'SUCCESS'  
            @webhook_payments = CashfreeResponse.create_receipt(params,company, @current_user, @fy_name.year.name,@from_account,@to_account,@request,@tax_account)
        if @webhook_payments.valid?
              @webhook_payments.save_with_ledgers
              @webhook_payments.update_included_invoice_online_status
              @webhook_payments.register_user_action(request.remote_ip, 'Received CashFree online Payment')
              @webhook_payments.create_online_payment_histories    
            end
            @expense = CashfreeResponse.create_expense(params, company, @current_user,@fy_name.year.name,@from_account, @to_expense_account,@request,@tax_account)
            if @expense.valid?
              @expense.save_expense_with_ledgers(@to_expense_account,@tax_account,'CashFree')
              @expense.tax_line_items.each do |tax_line_item|
              @expense.expense_line_items.each do |line_item|
                logger.debug line_item.expense_taxes.inspect
                expense=ExpenseTax.new(:expense_line_item_id=>line_item.id, :account_id=>tax_line_item.account_id)
                expense.save!
              end
            end
              @expense.register_user_action(request.remote_ip, 'Created for CashFree online payment')
            end
      end
    end
    redirect_to controller: 'signup', action: 'new', plan: 'Trial', cf_source: params[:orderId]


    # The webhook doesn't require a response but let's make sure
    # we don't send anything
       # render :nothing => true

  end


end
