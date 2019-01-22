class VoucherSetting < ActiveRecord::Base
  scope :by_voucher_type, lambda { |voucher_type, company| where(:voucher_type=>voucher_type, :company_id=>company) }
  belongs_to :company

  VOUCHERS = {1=>'Estimate', 2=>'ReceiptVoucher', 3=>'IncomeVoucher', 4=>'Expense', 5=>'Purchase',
      6=>'PurchaseOrder', 7=>'PaymentVoucher', 8=>'Withdrawal', 9=>'Deposit', 10=>'TransferCash',
      11=>'Journal', 12=>'Saccounting', 13=>'DebitNote', 14=>'CreditNote', 15=> "StockIssueVoucher",
      16=>'StockReceiptVoucher', 17=>'StockTransferVoucher', 18=>'StockWastageVoucher', 19=>'SalesOrder',
      20 =>'DeliveryChallan', 21=>"PurchaseReturn", 22=>"InvoiceReturn", 23 => 'ReimbursementNote', 24 => 'ReimbursementVoucher',
      25 =>'GstrAdvanceReceiptVoucher', 26 => 'GstrAdvancePaymentVoucher', 27 => 'GstCreditNote', 28 => 'GstDebitNote'}

  def custom_sequence?
    voucher_number_strategy==2
  end

  def change_voucher_number_strategy(params)
    new_strategy = params[:voucher_number_strategy].to_i
    voucher_type = params[:voucher_type]
    customer_notes = params[:customer_notes] unless params[:customer_notes].blank?
    terms_and_conditions = params[:terms_and_conditions] unless params[:terms_and_conditions].blank?
    if new_strategy == 1
      update_attributes(:voucher_number_strategy => new_strategy, :prefix=>params[:prefix], :suffix=>params[:suffix], :customer_notes=> customer_notes, :terms_and_conditions=> terms_and_conditions)
      unless VOUCHERS[voucher_type.to_i].blank?
        voucher_sequence = "#{VOUCHERS[voucher_type.to_i]}Sequence".constantize.find_by_company_id(company_id)
        if voucher_sequence.blank?
          starting_sequence = params[:starting_sequence].blank? ? 0 : (params[:starting_sequence].to_i - 1)
          "#{VOUCHERS[voucher_type.to_i]}Sequence".constantize.create!(:company_id=>company_id, :"#{VOUCHERS[voucher_type.to_i].underscore}_sequence"=>starting_sequence )
        else
          starting_sequence = params[:starting_sequence].blank? ? 0 : (params[:starting_sequence].to_i - 1)
          voucher_sequence.update_attributes(:"#{VOUCHERS[voucher_type.to_i].underscore}_sequence"=>starting_sequence)
        end
      end
    else
      update_attributes(:voucher_number_strategy=> new_strategy, :customer_notes=> customer_notes, :terms_and_conditions=> terms_and_conditions)
    end
  end

  def customize_number(default_prefix)
    "#{prefix.blank? ? default_prefix : prefix}/" + company.send("#{VOUCHERS[voucher_type].underscore}_sequence").send("#{VOUCHERS[voucher_type].underscore}_number").to_s + sfx=suffix.blank? ? '' : "/#{suffix}"
  end

  def next_number
   company.send("#{VOUCHERS[voucher_type].underscore}_sequence").increment_counter
  end

  def cancel_number
   company.send("#{VOUCHERS[voucher_type].underscore}_sequence").decrement_counter
  end

        def gstr_advance_receipt_voucher_number(company)
          voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 25).first
            if voucher_setting.voucher_number_strategy == 0
              "ARCPT"+Time.now.to_i.to_s
            elsif voucher_setting.voucher_number_strategy == 1
              voucher_setting.customize_number('ARCPT')
             
            end
        end
	def gstr_advance_payment_voucher_number(company)
		voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 26).first
		if voucher_setting.voucher_number_strategy == 0
			"APYMT"+Time.now.to_i.to_s
		elsif voucher_setting.voucher_number_strategy == 1
		 	voucher_setting.customize_number('APYMT')
		end
	end

  class << self

def next_gstr_advance_receipt_voucher_write(company)
      voucher_setting = VoucherSetting.where(:company_id=>company, :voucher_type=> 25).first
      if voucher_setting.voucher_number_strategy == 1 

        voucher_setting.next_number
         

      end
    end

    def next_gstr_advance_payment_voucher_write(company)
      voucher_setting = VoucherSetting.where(:company_id=>company, :voucher_type=> 26).first
      if voucher_setting.voucher_number_strategy == 1 

        voucher_setting.next_number
         

      end
    end
 
    def add_default_voucher_number_strategy(company)
      #created shorcut method here as we have fixed number of vouchers
      # voucher_count = company.plan.is_inventoriable? ? 20 : 14
      # voucher_count.times do |i|
      #   VoucherSetting.create!(:company_id=> company.id, :voucher_number_strategy=> 1, :voucher_type=>(i+1) )
      #   "#{VOUCHERS[i+1]}Sequence".constantize.create!(:company_id=>company.id, :"#{VOUCHERS[i+1].underscore}_sequence"=>0 )
      # end
      vouchers=company.get_allowed_vouchers
      vouchers.sort.each do |key, value|
        VoucherSetting.create!(:company_id=> company.id, :voucher_number_strategy=>1, :voucher_type=>key.to_i)
        "#{VOUCHERS[key]}Sequence".constantize.create!(:company_id=>company.id, :"#{VOUCHERS[key].underscore}_sequence"=>0 )
      end
    end

    def next_invoice_return_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 22).first
      if voucher_setting.voucher_number_strategy == 0
        "INVRT"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('INVRT')
      end
    end

    def next_purchase_return_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 21).first
      if voucher_setting.voucher_number_strategy == 0
        "PURRT"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('PURRT')
      end
    end

    def next_estimate_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 1).first
      if voucher_setting.voucher_number_strategy == 0
        "EST"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('EST')
      end
    end

    def next_receipt_voucher_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 2).first
      if voucher_setting.voucher_number_strategy == 0
        "RCPT"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('RCPT')
      end
    end

    def next_receipt_voucher_write(company)
      voucher_setting = VoucherSetting.where(:company_id=>company, :voucher_type=> 2).first
      if voucher_setting.voucher_number_strategy == 1 
        voucher_setting.next_number
      end
    end
    
#------------------------------------------------------------------------------------------------
    def next_income_voucher_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 3).first
      if voucher_setting.voucher_number_strategy == 0
        "OINC"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('OINC')
      end
    end

    def next_expense_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 4).first
      if voucher_setting.voucher_number_strategy == 0
        "EXP"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('EXP')
      end
    end

#------------------------------ Purchase ------------------------------------------------------------

    def next_purchase_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 5).first
      if voucher_setting.voucher_number_strategy == 0
        "PUR"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('PUR')
      end
    end

    def next_purchase_write(company)
      voucher_setting = VoucherSetting.where(:company_id=>company, :voucher_type=> 5).first
      if voucher_setting.voucher_number_strategy == 1 
        voucher_setting.next_number
             end
    end
#---------------------------------------Gst Debit Note-------------------------------------------------------------

    def next_gst_debit_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 28).first
      if voucher_setting.voucher_number_strategy == 0
        "GDN"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('GDN')
      end
    end

    def next_gst_debit_write(company)
      voucher_setting = VoucherSetting.where(:company_id=>company, :voucher_type=> 28).first
      if voucher_setting.voucher_number_strategy == 1 
        voucher_setting.next_number
      end
    end
#---------------------------Purchase Oreder------------------------------------------------------------------------   

    def next_purchase_order_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 6).first
      if voucher_setting.voucher_number_strategy == 0
        "PO"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('PO')
      end
    end

        def next_purchase_order_write(company)
      voucher_setting = VoucherSetting.where(:company_id=>company, :voucher_type=> 6).first
      if voucher_setting.voucher_number_strategy == 1 
        voucher_setting.next_number
             end
    end

#-----------------------------------------------------------------------------------------------------------------

    def next_payment_voucher_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 7).first
      if voucher_setting.voucher_number_strategy == 0
        "PYMT"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('PYMT')
      end
    end

    def next_withdrawal_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 8).first
      if voucher_setting.voucher_number_strategy == 0
        "WTDR"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('WTDR')
      end
    end

    def next_deposit_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 9).first
      if voucher_setting.voucher_number_strategy == 0
        "DPST"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('DPST')
      end
    end

    def next_transfer_cash_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 10).first
      if voucher_setting.voucher_number_strategy == 0
        "TRNS"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('TRNS')
      end
    end

    def next_journal_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 11).first
      if voucher_setting.voucher_number_strategy == 0
        "JRNL"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('JRNL')
      end
    end
    
    def next_journal_write(company)
      voucher_setting = VoucherSetting.where(:company_id=>company, :voucher_type=> 11).first
      if voucher_setting.voucher_number_strategy == 1 
        voucher_setting.next_number
             end
    end
    
    # def cancel_journal_write(company)
    #   voucher_setting = VoucherSetting.where(:company_id=>company, :voucher_type=> 11).first
    #   if voucher_setting.voucher_number_strategy == 1 
    #     voucher_setting.cancel_number
  #            end
    # end 
#-----------------------------------------------------------------------------
    def next_saccounting_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 12).first
      if voucher_setting.voucher_number_strategy == 0
        "SACC"+Time.now.to_i.to_s
      else
        voucher_setting.customize_number('SACC')
      end
    end

    def next_debit_note_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 13).first
      if voucher_setting.voucher_number_strategy == 0
        "DBT"+(Time.now.to_i.to_s)
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('DBT')
      end
    end
#------------------------------------ReimbursementNote & ReimbursementVoucher numbers---------------------------------------------------
    def next_reimbursement_note_number(company)
      voucher_setting = VoucherSetting.where(:company_id => company.id, :voucher_type => 23).first
      if voucher_setting.voucher_number_strategy == 0
        "RIM"+(Time.noe.to_i.to_s)
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('RIM')
      end
    end

    def next_reimbursement_note_write(company_id)
      voucher_setting = VoucherSetting.where(:company_id => company_id, :voucher_type => 23).first
      if voucher_setting.voucher_number_strategy == 1
        voucher_setting.next_number
      end
    end

    def next_reimbursement_voucher_number(company)
      voucher_setting = VoucherSetting.where(:company_id => company.id, :voucher_type => 24).first
      if voucher_setting.voucher_number_strategy == 0
        "RIV"+(Time.noe.to_i.to_s)
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('RIR')
      end
    end

    def next_reimbursement_voucher_write(company_id)
      voucher_setting = VoucherSetting.where(:company_id => company_id, :voucher_type => 24).first
      if voucher_setting.voucher_number_strategy == 1
        voucher_setting.next_number
      end
    end
#-------------------------------------------------------------------------------------------------------------------------------------

    def return_invoice_next_credit_note_number(invoice_return)
      voucher_setting = VoucherSetting.where(:company_id=>invoice_return.company.id, :voucher_type=> 14).first
       voucher_setting.customize_number('CRD')
    end
    def next_credit_note_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 14).first
      if voucher_setting.voucher_number_strategy == 0
        "CRD"+(Time.now.to_i.to_s)
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('CRD')
      end
    end

#---------------------------------GST Credit Note Voucher------------------------------------------------------------
    
    def next_gst_credit_note_number(company_id)
      voucher_setting = VoucherSetting.where(:company_id=>company_id, :voucher_type=> 27).first
      if voucher_setting.voucher_number_strategy == 0
        "GCN"+(Time.now.to_i.to_s)
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('GCN')
      end
    end

    def next_gst_credit_note_number_write(company_id)
      voucher_setting = VoucherSetting.where(:company_id => company_id, :voucher_type => 27).first
      if voucher_setting.voucher_number_strategy == 1
        voucher_setting.next_number
      end
    end
#------------------------------------------------------------------------------------------------------------------

    def next_stock_issue_voucher_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 15).first
      if voucher_setting.voucher_number_strategy == 0
        "STKISUE"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('STKISUE')
      end
    end

    def next_stock_receipt_voucher_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 16).first
      if voucher_setting.voucher_number_strategy == 0
        "STKRCPT"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('STKRCPT')
      end
    end

    def next_stock_transfer_voucher_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 17).first
      if voucher_setting.voucher_number_strategy == 0
        "STKTRAN"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('STKTRAN')
      end
    end

    def next_stock_wastage_voucher_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 18).first
      if voucher_setting.voucher_number_strategy == 0
        "STKWST"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('STKWST')
      end
    end

    def next_sales_order_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 19).first
      if voucher_setting.voucher_number_strategy == 0
        "SLSODR"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('SLSODR')
      end
    end

    def next_delivery_challan_number(company)
      voucher_setting = VoucherSetting.where(:company_id=>company.id, :voucher_type=> 20).first
      if voucher_setting.voucher_number_strategy == 0
        "DLC"+Time.now.to_i.to_s
      elsif voucher_setting.voucher_number_strategy == 1
        voucher_setting.customize_number('DLC')
      end
    end

    def get_strategy(company, voucher_type)
      strategy={}
      voucher_setting=VoucherSetting.where(:company_id=>company, :voucher_type=> voucher_type).first
      strategy['voucher_number_strategy']=voucher_setting.blank? ? 0 : voucher_setting.voucher_number_strategy
      strategy['prefix']=voucher_setting.blank? ? "" : voucher_setting.prefix
      strategy['suffix']=voucher_setting.blank? ? "" : voucher_setting.suffix
      strategy['voucher_type']=voucher_setting.voucher_type
      strategy['customer_notes']=voucher_setting.customer_notes
      strategy['terms_and_conditions']=voucher_setting.terms_and_conditions
      if voucher_setting.blank?
        strategy['voucher_sequence']=''
      else
        voucher_sequence = "#{VOUCHERS[voucher_setting.voucher_type]}Sequence".constantize.find_by_company_id(company)
        strategy['voucher_sequence']=voucher_sequence.blank? ? '' : (voucher_sequence.send("#{VOUCHERS[voucher_setting.voucher_type].underscore}_sequence") + 1)
      end
      strategy.to_json
    end
  end
end
