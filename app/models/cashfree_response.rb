class CashfreeResponse < ActiveRecord::Base
	require 'digest/hmac'
belongs_to :cashfree_payment_links, :primary_key => 'order_id'


class << self

	def create_payment(params,remote_ip)

		 payment=CashfreeResponse.new
		 payment.order_id=params[:orderId]
		 payment.order_amount  = params[:orderAmount]  
		 payment.reference_id=params[:referenceId]
		 payment.tx_status=params[:txStatus]
		 payment.payment_mode=params[:paymentMode]
		 payment.tx_message=params[:txMsg]
		 payment.tx_time=params[:txTime]
		 payment.signature=params[:txTime]
		 payment.remote_ip=remote_ip
		 payment.save!
  	end


  	 def create_receipt(params, company, user,fyr,from_account,to_account,request,tax_account)
      cess_accounts= parent_child_accounts(company.id,tax_account.id)
      receipt_voucher = ReceiptVoucher.new
      receipt_voucher.voucher_number = VoucherSetting.next_receipt_voucher_number(company)
      receipt_voucher.voucher_date= Time.zone.now.to_date
      receipt_voucher.received_date = Time.zone.now.to_date
      receipt_voucher.description="Received via CashFree online payment"
      receipt_voucher.company_id = company.id
      receipt_voucher.created_by = user.id
      tax_detail = DutiesAndTaxesAccounts.find_by_id(tax_account.accountable_id)
      tax_percent= tax_detail.tax_rate/tax_detail.calculate_on_percent
      cess_percent=0
      cess_accounts.each do |cess_account|
            cess_detail = DutiesAndTaxesAccounts.find_by_id(cess_account.accountable_id)
            cess_percent+= cess_detail.tax_rate/tax_detail.calculate_on_percent
      end

            if params[:paymentMode].to_s == "DEBIT_CARD" || params[:paymentMode].to_s == "CREDIT_CARD"
                fees_amount= 0.019*params[:orderAmount].to_f
                receipt_voucher.amount = (params[:orderAmount].to_f-((1+tax_percent+cess_percent)*fees_amount))
            elsif params[:paymentMode].to_s == "NET_BANKING"
                fees_amount= (0.019*params[:orderAmount].to_f > 99) ? 99 : 0.019*params[:orderAmount].to_f
                receipt_voucher.amount = (params[:orderAmount].to_f-((1+tax_percent+cess_percent)*fees_amount))
            elsif params[:paymentMode].to_s == "MobiKwik" || params[:paymentMode].to_s == "OLA" || params[:paymentMode].to_s == "FreeCharge"
                fees_amount= 0.0225*params[:orderAmount].to_f 
                receipt_voucher.amount = (params[:orderAmount].to_f-((1+tax_percent+cess_percent)*fees_amount))
            else
                fees_amount= 0.019*params[:orderAmount].to_f
                receipt_voucher.amount = (params[:orderAmount].to_f-((1+tax_percent+cess_percent)*fees_amount))
            end


        
      receipt_voucher.invoice_id=request.invoice_id

      receipt_voucher.from_account_id =from_account.id
      receipt_voucher.to_account_id =to_account.account_id

      receipt_voucher.fin_year = fyr

      if receipt_voucher.invoices_receipts.where(:invoice_id=>receipt_voucher.invoice_id).blank?
            invoice_receipt=InvoicesReceipt.new(:invoice_id=>receipt_voucher.invoice_id, :tds_amount=>nil, :amount=>receipt_voucher.amount)
            receipt_voucher.invoices_receipts<<invoice_receipt
        end


      receipt_voucher.payment_detail = fetch_payment_details
      receipt_voucher.payment_detail.transaction_reference=params[:referenceId]
      receipt_voucher.payment_detail.amount = receipt_voucher.amount
      receipt_voucher
      end

    def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
        " #{voucher_number} for customer #{from_account_name} for amount #{amount}", action, branch_id)
    end

    def fetch_payment_details

        payment = CardPayment.new
        logger.debug payment.inspect
        payment.payment_date = Time.zone.now.to_date
        payment
      
    end

    def create_expense(params, company, user, fyr,from_account,to_account,request,tax_account)
      cess_accounts= parent_child_accounts(company.id,tax_account.id)
      expense = Expense.new

      expense.voucher_number = VoucherSetting.next_expense_number(company)
      expense.expense_line_items.build
      expense.expense_date = Time.zone.now.to_date
      expense.company_id = company.id
      expense.created_by = user.id
      expense.company_id = company.id
      expense.status_id=0 if expense.credit_expense?

      if params[:paymentMode].to_s == "DEBIT_CARD" || params[:paymentMode].to_s == "CREDIT_CARD"
           expense.total_amount=(0.019*params[:orderAmount].to_f)
      elsif params[:paymentMode].to_s == "NET_BANKING"
         expense.total_amount = (0.019*params[:orderAmount].to_f > 99) ? 99 : 0.019*params[:orderAmount].to_f
      elsif params[:paymentMode].to_s == "MobiKwik" || params[:paymentMode].to_s == "OLA" || params[:paymentMode].to_s == "FreeCharge"
          expense.total_amount=(0.0225*params[:orderAmount].to_f)
      else
           expense.total_amount=(0.019*params[:orderAmount].to_f)
      end

      expense.account_id=from_account.id
      tax_detail = DutiesAndTaxesAccounts.find_by_id(tax_account.accountable_id)
      tax_percent= tax_detail.tax_rate/tax_detail.calculate_on_percent

      expense.currency_id = expense.account.get_currency_id unless expense.account_id.blank?
      if expense.currency_id.blank? || expense.account.get_currency == expense.company.currency_code
        expense.exchange_rate = 1
      end

      expense.expense_line_items=[]
      expense.expense_line_items<< ExpenseLineItem.new(:amount=>expense.total_amount,:account_id=>to_account.id,:type=>'ExpenseLineItem',:description=>' Expense for amount received by CashFree')
       expense.tax_line_items<< ExpenseLineItem.new(:amount=>expense.total_amount*tax_percent,:account_id=>tax_account.id,:tax=>1,:description=>'Service tax @ 14% on fees deducted by CashFree')
       cess_accounts.each do |cess_account|
            cess_detail = DutiesAndTaxesAccounts.find_by_id(cess_account.accountable_id)
            cess_percent= cess_detail.tax_rate/cess_detail.calculate_on_percent
            expense.tax_line_items<< ExpenseLineItem.new(:amount=>expense.total_amount*cess_percent,:account_id=>cess_account.id,:tax=>1,:description=>'Cess @ 0.5% on fees deducted by CashFree')
      end
       # expense.tax_line_items<< ExpenseLineItem.new(:amount=>expense.total_amount*cess_percent,:account_id=>cess_account.id,:tax=>1,:description=>'Cess @ 0.5% on fees deducted by CashFree')
      # expense.build_tax
      expense.total_amount=expense.calculate_total_amount
      expense.skip_account_validation=true

      expense
    end


    def parent_child_accounts(company_id,parent_id)
    accounts = Account.where(:company_id => company_id, :parent_id => parent_id, :deleted => false).reverse
    # accounts.push(self)
    accounts
  end

 end
end
