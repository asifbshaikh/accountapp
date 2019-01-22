require 'ostruct'

class Gstr2StatusResponseHandler
  def initialize(company, gstr_two, hash_data)
    @company = company
    @gstr_two = gstr_two
    @ost_res = OpenStruct.new(hash_data)
  end

  def process
    Rails.logger.debug "=============Gstr2StatusResponseHandler::process:: Form type #{@ost_res.form_typ}"
    if @ost_res.status_cd.eql?("P")
            @gstr_two.verified
    elsif @ost_res.status_cd.eql?("PE")

      #processed with errors
      if @ost_res.error_report.has_key?("b2b")
        Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2b invoices present #{@ost_res.error_report["b2b"]}"
        b2b_invs = @ost_res.error_report["b2b"]
        handle_B2B_invoices(b2b_invs)
      end
      #processing B2BUR invoice error
      if @ost_res.error_report.has_key?("b2bur")
        Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2BUR invoices error responses present "
        os_b2bur_invoices = OpenStruct.new @ost_res.error_report["b2bur"]
        Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2BUR invoices error responses present #{os_b2bur_invoices.inv} and #{os_b2bur_invoices.inv.inspect}"
       # handle_B2BUR_invoices(b2bur_invs)
      end

      # if @ost_res.error_report.has_key?("nil_supplies")
      #   Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: NIL_SUPPLIES invoices error responses present "
      #   os_nil_supplies_invoices = OpenStruct.new @ost_res.error_report["b2bur"]
      #   Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: NIL_SUPPLIES invoices error responses present #{os_b2bur_invoices.inv} and #{os_b2bur_invoices.inv.inspect}"
      #   #handle_NIL_invoices(b2bur_invs)
      # end

      #  if @ost_res.error_report.has_key?("txi")
      #   Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2BUR invoices error responses present "
      #   os_b2bur_invoices = OpenStruct.new @ost_res.error_report["b2bur"]
      #   Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2BUR invoices error responses present #{os_b2bur_invoices.inv} and #{os_b2bur_invoices.inv.inspect}"
      #   #handle_B2BUR_invoices(b2bur_invs)
      # end

      #  if @ost_res.error_report.has_key?("cdnur")
      #   Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2BUR invoices error responses present "
      #   os_b2bur_invoices = OpenStruct.new @ost_res.error_report["b2bur"]
      #   Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2BUR invoices error responses present #{os_b2bur_invoices.inv} and #{os_b2bur_invoices.inv.inspect}"
      #  # handle_B2BUR_invoices(b2bur_invs)
      # end

      # if @ost_res.error_report.has_key?("cdn")
      #   Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2BUR invoices error responses present "
      #   os_b2bur_invoices = OpenStruct.new @ost_res.error_report["b2bur"]
      #   Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2BUR invoices error responses present #{os_b2bur_invoices.inv} and #{os_b2bur_invoices.inv.inspect}"
      #   #handle_B2BUR_invoices(b2bur_invs)
      # end
       @gstr_two.partially_verified
     else
      @gstr_two.error_status
    end
    Rails.logger.debug "===========Gstr2StatusResponseHandler::process:: Status Code #{@ost_res.status_cd}"
    Rails.logger.debug "===========Gstr2StatusResponseHandler::process:: Error report #{@ost_res.error_report.inspect}"
    Rails.logger.debug "===========Gstr2StatusResponseHandler::process:: B2B section #{@ost_res.error_report["b2b"]}"
  end


  private 
    def handle_B2B_invoices(b2b_invs)
      b2b_invs.each do |inv|
        os_inv = OpenStruct.new inv
        Rails.logger.debug "==============Gstr2StatusResponseHandler::process:: The inv OpenStruct is #{os_inv.inspect}"
        Rails.logger.debug "==============Gstr2StatusResponseHandler::process:: B2b invoice Error is  #{os_inv.error_msg} #{os_inv.error_cd} "
        Rails.logger.debug "==============Gstr2StatusResponseHandler::process:: B2b invoice details are  #{os_inv.inv.class}"
        error_msg = os_inv.error_msg
        error_cd = os_inv.error_cd
        invoices_arr = os_inv.inv
        invoices_arr.each do |invoice|
          os_invoice = OpenStruct.new invoice
          inv_nu = os_invoice.inum
          inv_dt = os_invoice.idt
          @gstr_two.update_purchase_item(inv_nu, inv_dt, error_cd, error_msg)
          Rails.logger.debug "=============Gstr2StatusResponseHandler::process:: B2b invoice is  #{os_invoice.inum} #{os_invoice.idt} #{os_invoice.pos}"                
        end
      end
      Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2b invoices processed"      
    end

    def handle_B2BUR_invoices(b2bur_invs)
      b2bur_invs.each do |inv|
        os_inv = OpenStruct.new inv
        Rails.logger.debug "==============Gstr2StatusResponseHandler::process:: The inv OpenStruct is #{os_inv.inspect}"
        Rails.logger.debug "==============Gstr2StatusResponseHandler::process:: B2b invoice Error is  #{os_inv.error_msg} #{os_inv.error_cd} "
        Rails.logger.debug "==============Gstr2StatusResponseHandler::process:: B2b invoice details are  #{os_inv.inv.class}"
        error_msg = os_inv.error_msg
        error_cd = os_inv.error_cd
        invoices_arr = os_inv.inv
        invoices_arr.each do |invoice|
          os_invoice = OpenStruct.new invoice
          inv_nu = os_invoice.inum
          inv_dt = os_invoice.idt
          @gstr_two.update_purchase_item(inv_nu, inv_dt, error_cd, error_msg)
          Rails.logger.debug "=============Gstr2StatusResponseHandler::process:: B2b invoice is  #{os_invoice.inum} #{os_invoice.idt} #{os_invoice.pos}"                
        end
      end
      Rails.logger.debug "===============Gstr2StatusResponseHandler::process:: B2b invoices processed"      
    end

    
end