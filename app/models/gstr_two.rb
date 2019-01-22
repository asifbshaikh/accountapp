class GstrTwo < ActiveRecord::Base
  belongs_to :company
  belongs_to :financial_year
  belongs_to :gst_return
  has_many :gstr_two_items
  has_one :gstr2_summary


  PURCHASE_CLASSIFICATION = { B2B: 0, B2BUR: 1, NIL: 6}.with_indifferent_access
  ADVANCE_PAYMENT = { INTER: 2, INTRA: 3}.with_indifferent_access
  GST_DEBIT_NOTE_CLASSIFICATION = { cdnr: 4, cd_nur: 5}.with_indifferent_access
  STATUS = {open: 0, uploaded: 1, partially_verified:2, verified: 3, final: 4, processing: 5, error:6}

  class << self
   def create_return(company, gst_return, due_date)
    attr = {:company_id => company.id, :financial_year_id => company.financial_years.last.id, :month => gst_return.month, :gst_return_id => gst_return.id, :due_date => due_date, :year => Time.now.to_date.year}
    gstr_two = (GstrTwo.find_by_company_id_and_gst_return_id(company.id, gst_return.id) || GstrTwo.create!(attr))
      #GstrTwo.create!(:company_id => company.id, :financial_year_id => company.financial_years.last.id, :month => gst_return.month, :gst_return_id => gst_return.id, :due_date => due_date)
    end
  end


  def status_name
    STATUS.key(status)
  end

  def return_period
    "#{self.month.to_s.rjust(2,'0')}#{self.year}"
  end

  def processing
    update_attributes(:status => STATUS[:processing])
  end

  #This method marks the GSTR Two status as failed
  def upload_failed
    update_attributes(:status => STATUS[:failed])
  end

  #This method marks the GSTR Two status as failed
  def verified
    update_attributes(:status => STATUS[:verified])
  end

  #This method marks the GSTR Two status as failed
  def partially_verified
    update_attributes(:status => STATUS[:partially_verified])
  end

  def error_status
     update_attributes(:status => STATUS[:error])
  end
 
  def processing?
    status == STATUS[:processing]
  end

  def can_verify?
    Rails.logger.debug "GstrTwo::can_verify:: the value of status is #{status} and #{STATUS[:uploaded]}"
    status == STATUS[:uploaded] || status == [:partially_verified] || status == STATUS[:verified] || status == [:failed]
  end

  def status_name
    STATUS.key(status)
  end

  def fetch_general_info(type)
    general_info = Hash.new()
    if type =="CDNR"
      general_info = calculate_details(fetch_items(type),'GstDebitNote')
    elsif type =="AP"
      general_info = calculate_details(fetch_items(type),'GstrAdvancePayment')
    else  
      general_info = calculate_details(fetch_items(type),'Purchase')
    end
    general_info
  end

  def fetch_items(type)
    logger.debug "type #{type.inspect}"
    if type.present?
      if type == 'CDNR'
        gstr_two_items.where(:voucher_type => 'GstDebitNote')
      elsif type=='AP'
        gstr_two_items.where(:voucher_type => 'GstrAdvancePayment')
      elsif type == "EXPENSE"
        gstr_two_items.where(:voucher_type => 'Expense')
      else
        gstr_two_items.where(:voucher_classification => PURCHASE_CLASSIFICATION[type.to_s], :voucher_type => 'Purchase')
      end 
    else
      gstr_two_items.where(:voucher_type => 'Purchase')
    end
  end

  def calculate_details(purchase_for_the_month,type)
    logger.debug "#{purchase_for_the_month.inspect}"
    details =Hash.new()
    details[:count] =0
    details[:taxable_amount]=0
    details[:total_cgst]=0
    details[:total_sgst]=0
    details[:total_igst]=0
    details[:total_amount]=0

    purchase_for_the_month.each do |voucher|
      if voucher.voucher_type == "Purchase"
        purchase = voucher.voucher_type.constantize.find_by_id(voucher.voucher_id)
        details[:count]+=1
        details[:taxable_amount]+=purchase.sub_total
        details[:total_cgst] += purchase.cgst
        details[:total_sgst] += purchase.sgst
        details[:total_igst] += purchase.igst
        details[:total_amount] +=purchase.total_amount
      elsif voucher.voucher_type == "GstrAdvancePayment"
        adv_payment = voucher.voucher_type.constantize.find_by_id(voucher.voucher_id)
        details[:count]+=1
        details[:taxable_amount]+=adv_payment.sub_total
        details[:total_cgst] += adv_payment.cgst
        details[:total_sgst] += adv_payment.sgst
        details[:total_igst] += adv_payment.igst
        details[:total_amount] +=adv_payment.total_amount

      elsif voucher.voucher_type == "GstDebitNote"
        deb_note = voucher.voucher_type.constantize.find_by_id(voucher.voucher_id)
        details[:count]+=1
        details[:taxable_amount]+=deb_note.sub_total
        details[:total_cgst] += deb_note.cgst
        details[:total_sgst] += deb_note.sgst
        details[:total_igst] += deb_note.igst
        details[:total_amount] +=deb_note.total_amount

      else
        expense =Expense.find_by_id(voucher.voucher_id)
        details[:count]+=1
        details[:taxable_amount]+=expense.sub_total
        details[:total_cgst] += expense.cgst
        details[:total_sgst] += expense.sgst
        details[:total_igst] += expense.igst
        details[:total_amount] +=expense.total_amount
      end
    end
    details
  end

  def calculate_itc_details(purchase_for_the_month,type)
    details =Hash.new()
    details[:itc_igst]=0
    details[:itc_cgst]=0
    details[:itc_sgst]=0
    purchase_for_the_month.each do |voucher|
      logger.debug "voucher #{voucher.inspect}"  
        #details[:count] = 1
       
        # details[:itc_cgst] += voucher[:cgst]
        # details[:itc_sgst] += voucher.params[:sgst]
        # details[:itc_igst] += voucher.params[:igst]
        # else
        # expense =Expense.find_by_id(voucher.voucher_id)
        # details[:count]+=1
        # details[:itc_igst]+=expense.expense_line_item.it_igst
        # details[:itc_cgst] += expense.expense_line_item.it_cgst
        # details[:itc_sgst] += expense.expense_line_item.it_sgst
    end
  end

  # def itc_details
  #   purchases = GstrTwoItem.where(:company_id => self.company_id,:voucher_type=>'Purchase')
  #   logger.debug "purchases #{purchases.inspect}"
  #   expenses = GstrTwoItem.where(:company_id => self.company_id,:voucher_type=>'Expense')
  #   values = Hash.new()
  #   keys = ['ip', 'no','cp','is']
  #   keys.each do |key|
  #     logger.debug "key #{key.inspect}"
  #     itc_purchase = Array.new
  #     # if key =='ip'
  #     #   itc_purchase = purchase.find_by_eligibility(:eligibility=>'ip')
  #     #   values[key] = calculate_itc_details(itc_purchase,'Purchase')
  #     # elsif key =='no'
  #     #   itc_purchase = purchase.find_by_eligibility(:eligibility=>'no')
  #     #   values[key] = calculate_itc_details(itc_purchase,'Purchase')
  #     # elsif key =='cp'
  #     #   itc_purchase = purchase.find_by_eligibility(:eligibility=>'cp')
  #     #   values[key] = calculate_itc_details(itc_purchase,'Purchase')
  #     # else
  #     #   itc_purchase = purchase.find_by_eligibility(:eligibility=>'is')
  #     #   values[key] = calculate_itc_details(itc_purchase,'Purchase')
  #     # end
  #     purchases.each do |voucher|
  #     purchase = Purchase.find_by_id(voucher.voucher_id)
  #     logger.debug "purchase #{purchase.inspect}"
  #     itc_value = purchase.purchase_line_items.where(:eligibility=>key)
  #     if itc_value.present?
  #      itc_purchase << itc_value
  #    end
  #     logger.debug "itc purchase #{itc_purchase.inspect}"
  #   end
  #     values[key] = calculate_itc_details(itc_purchase,'Purchase')
  #   end
  #   values
  # end

  def add_purchase(purchase)
    manager = PurchaseManager.new
    purchase_type = manager.classify_purchase(purchase)
    Rails.logger.info("GstrTwo::add_purchase::The purchase_type is #{purchase_type}")
    attr = {:gstr_two_id => self.id, :company_id => self.company_id, 
      :voucher_id => purchase.id, :voucher_type => 'Purchase', :voucher_number => purchase.purchase_number,
      :voucher_classification => PURCHASE_CLASSIFICATION[purchase_type],
      :status => STATUS[:open]}
      gstr_two_items << (GstrTwoItem.find_by_gstr_two_id_and_company_id_and_voucher_id_and_voucher_type(id, company_id, purchase.id, 'Purchase') || GstrTwoItem.new(attr) )
  end


  #  def add_expense(expense)
  #   manager = ExpenseManager.new
  #   expense_type = manager.classify_expense(expense)
   
  #   attr = {:gstr_two_id => self.id, :company_id => self.company_id, 
  #    :voucher_type => 'Expense',
  #     :voucher_id => expense.id,:voucher_classification =>  PURCHASE_CLASSIFICATION[expense_type],
  #     :voucher_number => @expense.voucher_number,STATUS[:open]}
  #     gstr_two_items << (GstrTwoItem.find_by_gstr_two_id_and_company_id_and_voucher_id_and_voucher_type(id, company_id, expense.id, 'Expense') || GstrTwoItem.new(attr) )
  # end

  def add_gst_debit_note(gst_debit_note)
    logger.debug "self id #{self.id}"
    rule = GstDebitNoteRule.new
    gst_debit_note_type = rule.classify(gst_debit_note)
    attr = {:gstr_two_id => self.id, :company_id => self.company_id, 
      :voucher_id => gst_debit_note.id, :voucher_type => 'GstDebitNote', :voucher_number => gst_debit_note.gst_debit_note_number,
      :voucher_classification => GST_DEBIT_NOTE_CLASSIFICATION[gst_debit_note_type],
      :status => STATUS[:open]}
      gstr_two_items << (GstrTwoItem.find_by_gstr_two_id_and_company_id_and_voucher_id_and_voucher_type(id, company_id, gst_debit_note.id, 'GstDebitNote') || GstrTwoItem.new(attr) )
    end

    def add_gstr_advance_payment(advance_payment)
      if advance_payment.intra_state_supply
        type ='INTRA'
      else
       type ='INTER'
     end
     attr = {:gstr_two_id => self.id, :company_id => self.company_id, 
      :voucher_id => advance_payment.id, :voucher_type => 'GstrAdvancePayment', :voucher_number => advance_payment.voucher_number,
      :voucher_classification => ADVANCE_PAYMENT[type],
      :status => STATUS[:open]}

      gstr_two_items << (GstrTwoItem.find_by_gstr_two_id_and_company_id_and_voucher_id_and_voucher_type(id, company_id, advance_payment.id, 'GstrAdvancePayment') || GstrTwoItem.new(attr) )

    end

    def update_gstr_advance_payment(advance_payment)
      if advance_payment.intra_state_supply
        type ='INTRA'
      else
       type ='INTER'
     end
     attr = {:gstr_two_id => self.id, :company_id => self.company_id, 
      :voucher_id => advance_payment.id, :voucher_type => 'GstrAdvancePayment', :voucher_number => advance_payment.voucher_number,
      :voucher_classification => ADVANCE_PAYMENT[type],
      :status => STATUS[:open]}
      gstr_two_items << (GstrTwoItem.find_by_company_id_and_voucher_id_and_voucher_type(company_id, advance_payment.id, 'GstrAdvancePayment'))
    end

    def add_expense(expense)
      logger.debug "GstrTwo::add_expense::BEGIN"
      classifier = ExpenseClassifier.new
      attr = {:gstr_two_id => self.id, :company_id => self.company.id,
        :voucher_type => 'Expense', :voucher_id => expense.id, 
        :voucher_classification => PURCHASE_CLASSIFICATION[classifier.classify_expense(expense)],
        :voucher_number => expense.voucher_number, :status => STATUS[:open]}
      logger.debug "GstrTwo::add_expense:: The attr of new GstrTwoItem are #{attr.inspect}=========="
      self.gstr_two_items << (GstrTwoItem.find_by_gstr_two_id_and_company_id_and_voucher_id_and_voucher_type(id, self.company_id, expense.id, 'Expense') || GstrTwoItem.new(attr))

      logger.debug "GstrTwo::add_expense:: Added the expense to GstrTwo================="
    end

    def check_validity_of_otp params
      otp =params[:otp]
      encryption_utility =  EncryptionUtility.new()
      encrypt_otp = encryption_utility.encrypt_otp(otp)
      request_token = SessionEstablishmentService.new()
      auth_response = request_token.request_token(encrypt_otp)
      auth_response

    end

     def update_purchase_item(inv_nu, inv_idt, error_cd, error_msg)
    #first find purchase[FIXME] Later add purchase_voucher_number in gstr_one_item table
    fmt_inv_dt = Date.parse(inv_idt)
    purchase = company.purchases.find_by_purchase_number_and_record_date(inv_nu, fmt_inv_dt)
    gstr_two_item = gstr_two_items.find_by_voucher_id_and_voucher_type(purchase.id, 'Purchase')
    gstr_two_item.update_error_status(error_cd, error_msg)
  end



    def self.check_gstr2_upload_status(company_id, gstr_id)
      results = self.where(:company_id => company_id,:id=>gstr_id)
      if status = results.present? ? status = 1 : status = 0
        return status
      end
    end

    def uploaded(gst_reference)
      update_attributes(:status => STATUS[:uploaded], :gst_reference => gst_reference)
      gstr_two_items.update_all("status = #{GstrTwoItem::STATUS[:uploaded]}")
    end

end
