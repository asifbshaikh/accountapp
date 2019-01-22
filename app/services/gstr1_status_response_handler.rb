require 'ostruct'

class Gstr1StatusResponseHandler
  def initialize(company, gstr_one, hash_data)
    @company = company
    @gstr_one = gstr_one
    @ost_res = OpenStruct.new(hash_data)
  end

  def process
    Rails.logger.debug "=============Gstr1StatusResponseHandler::process:: Form type #{@ost_res.form_typ}"
    if @ost_res.status_cd.eql?("P")
      @gstr_one.verified
      @gstr_one.update_errors
    elsif @ost_res.status_cd.eql?("PE")
      #processed with errors
      if @ost_res.error_report.has_key?("b2b")
        Rails.logger.debug "===============Gstr1StatusResponseHandler::process:: B2b invoices present #{@ost_res.error_report["b2b"]}"
        b2b_invs = @ost_res.error_report["b2b"]
        handle_B2B_invoices(b2b_invs)
      end
      #processing B2CL invoice error
      if @ost_res.error_report.has_key?("b2cl")
        Rails.logger.debug "===============Gstr1StatusResponseHandler::process:: b2cl invoices error responses present "
        os_b2cl_invoices = OpenStruct.new @ost_res.error_report["b2cl"]
        Rails.logger.debug "===============Gstr1StatusResponseHandler::process:: B2CL invoices error responses present #{os_b2cl_invoices.inv} and #{os_b2cl_invoices.inv.inspect}"
      end
      #processing B2CS invoice errors
      @gstr_one.partially_verified
    end
    Rails.logger.debug "===========Gstr1StatusResponseHandler::process:: Status Code #{@ost_res.status_cd}"
    Rails.logger.debug "===========Gstr1StatusResponseHandler::process:: Error report #{@ost_res.error_report.inspect}"
    Rails.logger.debug "===========Gstr1StatusResponseHandler::process:: B2B section #{@ost_res.error_report["b2b"]}"
  end


  private 
    def handle_B2B_invoices(b2b_invs)
      b2b_invs.each do |inv|
        os_inv = OpenStruct.new inv
        Rails.logger.debug "==============Gstr1StatusResponseHandler::process:: The inv OpenStruct is #{os_inv.inspect}"
        Rails.logger.debug "==============Gstr1StatusResponseHandler::process:: B2b invoice Error is  #{os_inv.error_msg} #{os_inv.error_cd} "
        Rails.logger.debug "==============Gstr1StatusResponseHandler::process:: B2b invoice details are  #{os_inv.inv.class}"
        error_msg = os_inv.error_msg
        error_cd = os_inv.error_cd
        invoices_arr = os_inv.inv
        invoices_arr.each do |invoice|
          os_invoice = OpenStruct.new invoice
          inv_nu = os_invoice.inum
          inv_dt = os_invoice.idt
          @gstr_one.update_invoice_item(inv_nu, inv_dt, error_cd, error_msg)
          Rails.logger.debug "=============Gstr1StatusResponseHandler::process:: B2b invoice is  #{os_invoice.inum} #{os_invoice.idt} #{os_invoice.pos}"                
        end
      end
      Rails.logger.debug "===============Gstr1StatusResponseHandler::process:: B2b invoices processed"      
    end
end