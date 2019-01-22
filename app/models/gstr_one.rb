
require "encryption_utility"
require "session_establishment_service"

class GstrOne < ActiveRecord::Base
  belongs_to :company
  belongs_to :financial_year
  belongs_to :gst_return

  has_one :gstr1_summary
  has_many :gstr_one_items


INVOICE_CLASSIFICATION = { B2B: 0, B2CL: 1, B2CS: 2, EXP: 3, NIL: 4}.with_indifferent_access
GSTR_ADVANCE_RECEIPT_CLASSIFICATION = {INTRA: 7, INTER: 8}.with_indifferent_access  
GST_CREDIT_NOTE_CLASSIFICATION = { cdnr: 5, cd_nur: 6 }.with_indifferent_access
VOUCHER_TYPE_ALIAS = {B2B: 'B2B Invoice', B2CL: 'B2CL Invoice(Large)', B2CS: 'B2CS Invoice(Small)', EXP: 'Export Invoices', CDNR: 'Credit Notes', AR: 'Advaance Receipts'}.with_indifferent_access
STATUS = {open: 0, uploaded: 1, partially_verified:2, verified: 3, final: 4, processing: 5, failed: 6}.with_indifferent_access



  class << self

    def create_return(company, gst_return, due_date)
      attr = {:company_id => company.id, :financial_year_id => company.financial_years.last.id, :month => gst_return.month, :gst_return_id => gst_return.id, :due_date => due_date, :year => Time.now.to_date.year}
      gstr_one = (GstrOne.find_by_company_id_and_gst_return_id(company.id, gst_return.id) || GstrOne.create!(attr))
    end

  end

  def status_name
    STATUS.key(status)
  end

  def return_period
    "#{self.month.to_s.rjust(2,'0')}#{self.year}"
  end

  def gross_values?
    (fy_gross_turnover <=0  || qtr_gross_turnover <= 0)
  end


  #add invoices to the getr_one report
  def add_invoice(invoice)
    Sidekiq.logger.debug "GstrOne::add_invoice::BEGIN"
    manager = InvoiceManager.new
    invoice_type = manager.classify_invoice(invoice)
    Sidekiq.logger.debug "GstrOne::add_invoice:: Invoice classified as #{invoice_type}"
    attr = {:gstr_one_id => self.id, :company_id => self.company_id, 
      :voucher_id => invoice.id, :voucher_type => 'Invoice', 
      :voucher_classification => INVOICE_CLASSIFICATION[invoice_type],
      :status => STATUS[:open]}
      present_gstr_one_item = GstrOneItem.find_by_company_id_and_voucher_id_and_voucher_type(company_id, invoice.id, 'Invoice')
      if present_gstr_one_item.blank?
        gstr_one_items << ( GstrOneItem.new(attr) )
      else
        present_gstr_one_item.update_attributes(:gstr_one_id => self.id)
      end
  end



def add_gstr_advance_receipt(gstr_advance_receipt)
  
   if gstr_advance_receipt.intra_state_supply
    type ='INTRA'
  else
    type ='INTER'
  end
attr = {:gstr_one_id => self.id, :company_id => self.company_id, 
      :voucher_id => gstr_advance_receipt.id, :voucher_type => 'GstrAdvanceReceipt', 
      :voucher_classification => GSTR_ADVANCE_RECEIPT_CLASSIFICATION[type],
      :status => STATUS[:open]}
    gstr_one_items << (GstrOneItem.find_by_gstr_one_id_and_company_id_and_voucher_id_and_voucher_type(id, company_id, gstr_advance_receipt.id,'GstrAdvanceReceipt') || GstrOneItem.new(attr) )
  end
  

  def add_gst_credit_note(gst_credit_note)
    rule = GstCreditNoteRule.new
    gst_credit_note_type = rule.classify(gst_credit_note)
    attr = {:gstr_one_id => self.id, :company_id => self.company_id, 
      :voucher_id => gst_credit_note.id, :voucher_type => 'GstCreditNote', 
      :voucher_classification => GST_CREDIT_NOTE_CLASSIFICATION[gst_credit_note_type],
      :status => STATUS[:open]}
    gstr_one_items << (GstrOneItem.find_by_gstr_one_id_and_company_id_and_voucher_id_and_voucher_type(id, company_id, gst_credit_note.id, 'GstCreditNote') || GstrOneItem.new(attr) )
  end

  def update_invoice_item(inv_nu, inv_idt, error_cd, error_msg)
    #first find invoice[FIXME] Later add invoice_voucher_number in gstr_one_item table
    fmt_inv_dt = Date.parse(inv_idt)
    logger.debug "++++++++++++++++++++++++++++++++++++++++++++++++ The fmt_inv_dt is #{fmt_inv_dt}"
    invoice = company.invoices.find_by_invoice_number_and_invoice_date(inv_nu, fmt_inv_dt)
    gstr_one_item = gstr_one_items.find_by_voucher_id_and_voucher_type(invoice.id, 'Invoice')
    gstr_one_item.update_error_status(error_cd, error_msg)
  end

  def remove_invoice(invoice_id)
    gstr_one_item = gstr_one_items.find_by_voucher_id_and_voucher_type(invoice_id, 'Invoice')
    gstr_one_item.destroy
  end

  def update_errors
    gstr_one_item = gstr_one_items.where(:voucher_type =>'Invoice').where("error_msg IS NOT NULL")
    gstr_one_item.each do |item|
      item.remove_error
    end
  end

  # def fetch_general_info(type)
  #   general_info = Hash.new()
  #   if type =="CDNR"
  #     general_info = calculate_details(fetch_items(type),'GstCreditNote')
  #   elsif type =="AR"
  #     general_info = calculate_details(fetch_items(type),'GstrAdvanceReceipt')
  #   else  
  #     general_info = calculate_details(fetch_items(type),'Invoice')
  #   end
  #   general_info
  # end


  def gstr_one_summary

    values = Hash.new()
    keys =['B2B','B2CL','B2CS','EXP','CDNR', 'AR']
     
   keys.each do |key|
    if key != 'CDNR' && key != 'AR'
        values[key] = calculate_details(fetch_items(key),key,'Invoice')
    elsif key =='CDNR'
        values[key] = calculate_details(fetch_items(key),key,'GstCreditNote')
    else
        values[key] = calculate_details(fetch_items(key),key,'GstrAdvanceReceipt')
    end
   end
      values["total"] = calculate_total(values)
      values
  end


  def calculate_total(items)
    totals = Hash.new()
    totals[:key] = "<b>Total</b>".html_safe
    totals[:count] = 0
    totals[:taxable_amount] = 0
    totals[:total_cgst] = 0
    totals[:total_sgst] = 0
    totals[:total_igst] = 0
    totals[:total_amount] = 0
    #  totals = details
    items.values.each do |item|


     totals[:count] += item[:count]       
     totals[:taxable_amount] += item[:taxable_amount]
     totals[:total_cgst] += item[:total_cgst]
     totals[:total_sgst] += item[:total_sgst]
     totals[:total_igst] += item[:total_igst]
     totals[:total_amount] += item[:total_amount]

   end
   totals
 end

 def fetch_items(type)
  summary = Hash.new()
  if type.present?
    if type == 'CDNR'
      summary = gstr_one_items.where(:voucher_type => 'GstCreditNote')
    elsif type=='AR'
     summary = gstr_one_items.where(:voucher_type => 'GstrAdvanceReceipt')
   else
     summary = gstr_one_items.where(:voucher_classification => INVOICE_CLASSIFICATION[type.to_s],:voucher_type => 'Invoice')
   end    
 else
  summary = gstr_one_items.where(:voucher_type => 'Invoice')
end 
summary
end

  def calculate_details(invoices,key, type) 
    details =Hash.new()
    details[:key] = VOUCHER_TYPE_ALIAS[key]
    details[:count] =0
    details[:taxable_amount]=0
    details[:total_cgst]=0
    details[:total_sgst]=0
    details[:total_igst]=0
    details[:total_amount]=0
   
    
    invoices.each do |voucher|
    
      invoice = type.constantize.find_by_id(voucher.voucher_id)
      details[:count]+=1
      details[:taxable_amount]+= invoice.sub_total
      details[:total_cgst] +=  invoice.cgst
      details[:total_sgst] +=  invoice.sgst
      details[:total_igst] +=  invoice.igst
      details[:total_amount] += invoice.total_amount
    end
    details
  end



  #This method marks the GSTR One status as upload and also updated the reference_key
  def uploaded(gst_reference)
    update_attributes(:status => STATUS[:uploaded], :gst_reference => gst_reference)
    gstr_one_items.update_all("status = #{GstrOneItem::STATUS[:uploaded]}")
  end

  #This method marks the GSTR One status as processing
  def processing
    update_attributes(:status => STATUS[:processing])
  end

  #This method marks the GSTR One status as failed
  def upload_failed
    update_attributes(:status => STATUS[:failed])
  end

  #This method marks the GSTR One status as failed
  def verified
    update_attributes(:status => STATUS[:verified])
  end

  #This method marks the GSTR One status as failed
  def partially_verified
    update_attributes(:status => STATUS[:partially_verified])
  end

  def processing?
    status == STATUS[:processing]
  end  

  def can_verify?
    Rails.logger.debug "GstrOne::can_verify:: the value of status is #{status} and #{STATUS[:uploaded]}"
    status == STATUS[:uploaded] || status == [:partially_verified] || status == STATUS[:verified] || status == [:failed]
  end

  def remove_invoice(invoice_id)
    item_to_be_deleted = gstr_one_items.find_by_voucher_id_and_voucher_type(invoice_id, 'Invoice')
    if item_to_be_deleted.present?
      gstr_one_items.delete(item_to_be_deleted)
    end
  end



  def  submit_for_processing(company_id, invoice_id)
   company = Company.find(company_id)
   invoice_for_filing = company.invoices.find_by_id(invoice_id)
   gstr_one_for_month = company.gstr_ones.find_by_month_and_financial_year_id(invoice_for_filing.invoice_date.month,company.financial_years.last.id)
   filed_invoice= company.gstr_one_items.find_by_voucher_id(invoice_id)
   # ActiveRecord::Base.transaction do

   if  gstr_one_for_month.present?

     if filed_invoice.present?
      manager = InvoiceManager.new
      invoice_type = manager.classify_invoice(invoice_for_filing)
      logger.debug filed_invoice.attributes.inspect
      filed_invoice.update_attributes(:status => 0,:voucher_classification => INVOICE_CLASSIFICATION[invoice_type])
      filed_invoice.gstr_one.update_attributes(:status => 0,:month => invoice_for_filing.invoice_date.month)

    else
      manager = InvoiceManager.new
      invoice_type = manager.classify_invoice(invoice_for_filing)
      invoice_entry = GstrOneItem.new(:gstr_one_id=> gstr_one_for_month.id,:company_id=> company_id,:voucher_id=>invoice_id,:voucher_type=>'Invoice',:voucher_classification=> INVOICE_CLASSIFICATION[invoice_type],:status=>0)
      gstr_one_for_month.gstr_one_items << invoice_entry
      gstr_one_for_month.save!

    end

  else
    invoice_item= GstrOne.new
    invoice_item.company_id=company_id
    invoice_item.month =  invoice_for_filing.invoice_date.month 
    invoice_item.financial_year_id = company.financial_years.last.id
    invoice_item.status = 0
    manager = InvoiceManager.new
    invoice_type = manager.classify_invoice(invoice_for_filing)
    invoice_entry =GstrOneItem.new(:gstr_one_id=>invoice_item.id,:company_id=> company_id,:voucher_id=>invoice_id,:voucher_type=>'Invoice',:voucher_classification=> INVOICE_CLASSIFICATION[invoice_type],:status=>0)
    invoice_item.gstr_one_items << invoice_entry
    invoice_item.save!

  end


     #    if filed_invoice.present?
     #      manager = InvoiceManager.new
       #  invoice_type = manager.classify_invoice(invoice_for_filing)
       #  logger.debug filed_invoice.attributes.inspect
     #      filed_invoice.update_attributes(:status => 1,:voucher_classification => INVOICE_CLASSIFICATION[invoice_type])
     #      filed_invoice.gstr_one.update_attributes(:status => 1,:month => invoice_for_filing.invoice_date.month)


     #    else
     #      invoice_item = company.gstr_ones.find_by_month(invoice_for_filing.invoice_date.month)
     #      if invoice_item.present?
     #         manager = InvoiceManager.new
         # invoice_type = manager.classify_invoice(invoice_for_filing)
         # invoice_entry =GstrOneItem.new(:gstr_one_id=>invoice_item.id,:company_id=> company_id,:voucher_id=>invoice_id,:voucher_type=>'Invoice',:voucher_classification=> INVOICE_CLASSIFICATION[invoice_type],:status=>1)
         # invoice_item.gstr_one_items << invoice_entry
         # invoice_item.save!
     #      else
         #        invoice_item= GstrOne.new
         #        invoice_item.company_id=company_id
         #        invoice_item.month =  invoice_for_filing.invoice_date.month 
         #        invoice_item.financial_year_id = company.financial_years.last.id
         #        invoice_item.status = 0
         #        manager = InvoiceManager.new
         #      invoice_type = manager.classify_invoice(invoice_for_filing)
         #      invoice_entry =GstrOneItem.new(:gstr_one_id=>invoice_item.id,:company_id=> company_id,:voucher_id=>invoice_id,:voucher_type=>'Invoice',:voucher_classification=> INVOICE_CLASSIFICATION[invoice_type],:status=>1)
         #        invoice_item.gstr_one_items << invoice_entry
      #           invoice_item.save!
      #     end

     #    end


      # end

    end


    # def fetch_data_for_month
    #   company.name.to_json

    # end 





      def check_validity_of_otp params
        otp =params[:otp]
        encryption_utility =  EncryptionUtility.new()
        encrypt_otp = encryption_utility.encrypt_otp(otp)
        request_token = SessionEstablishmentService.new()
        auth_response = request_token.request_token(encrypt_otp)
        auth_response

      end



    def self.check_gstr1_upload_status(company_id, gstr_id)
        results = self.where(:company_id => company_id,:id=>gstr_id)
        if status = results.present? ? status = 1 : status = 0
          return status
        end
    end

  end
