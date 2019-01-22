class GstrOneDatatable
 include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  INVOICE_CLASSIFICATION = { B2B: 0, B2CL: 1, B2CS: 2, EXP: 3, NIL: 4}.with_indifferent_access
  GSTR_ADVANCE_RECEIPT_CLASSIFICATION = {INTRA: 7, INTER: 8}.with_indifferent_access  
  TYPE= {'1' => "B2CL invoice", '2' => "B2CS invoice", '0' => "B2B invoice", '3' => "EXP", '4' => "NIL", '7' => "INTRA" , '8' =>"INTER" }
  STATUS = {'0' => "Not Upoaded",'1' => "Uploaded", '2' => "Submitted", '3' => "Final"}

  def initialize(view, company, current_user, financial_year, gstr_one,type)
    @view =view
    @company=company
    @gstr_one = gstr_one
    @current_user = current_user
    @financial_year=financial_year
    @type = params[:type]

  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => gstr_one_items.count,
      :iTotalDisplayRecords => gstr_one_items.total_count,
      :aaData => data
    }
  end

  private
    def data
      if @type.eql?("CDNR")
          gstr_one_items.where(:voucher_type => 'GstCreditNote').map do |one_item|
                  credit_note =GstCreditNote.find_by_id(one_item.voucher_id)
                  [
                    link_to(credit_note.gst_credit_note_number, gst_credit_note_path(credit_note)),
                    (credit_note.customer_name),
                    h(credit_note.gst_credit_note_date.strftime("%d-%m-%Y")),
                    format_currency(credit_note.sub_total),
                    format_currency(credit_note.tax),
                    format_currency(credit_note.total_amount),
                    TYPE[one_item.voucher_classification.to_s],  
                    STATUS[one_item.status.to_s],
                    one_item.error_msg
                  ]

                end

      elsif @type.eql?("AR")
            gstr_one_items.where(:voucher_type => 'GstrAdvanceReceipt').map do |one_item|
                  gstr_advance_receipt =GstrAdvanceReceipt.find_by_id(one_item.voucher_id)
                  [
                    link_to(gstr_advance_receipt.voucher_number, gstr_advance_receipt_path(gstr_advance_receipt)),
                    (gstr_advance_receipt.customer_name),
                    h(gstr_advance_receipt.voucher_date.strftime("%d-%m-%Y")),
                    format_currency(gstr_advance_receipt.sub_total),
                    format_currency(gstr_advance_receipt.tax),
                    format_currency(gstr_advance_receipt.amount),
                    TYPE[one_item.voucher_classification.to_s],  
                    STATUS[one_item.status.to_s],
                    one_item.error_msg
                  ]

                end


       else

                gstr_one_items.where(:voucher_type => 'Invoice').map do |one_item|
                  invoice =Invoice.find_by_id(one_item.voucher_id)
                  [
                    link_to(invoice.invoice_number, invoice_path(invoice)),
                    (invoice.customer_name),
                    h(invoice.invoice_date.strftime("%d-%m-%Y")),
                    format_currency(invoice.sub_total),
                    format_currency(invoice.tax),
                    format_currency(invoice.total_amount),
                    TYPE[one_item.voucher_classification.to_s],  
                    STATUS[one_item.status.to_s],
                    one_item.error_msg
                  ]

                end
        end
    end

    def gstr_one_items
      @gstr1s ||= fetch_items
    end


    def fetch_details

    end

    def fetch_items
      gstr1s = @gstr_one.fetch_items(@type)
      gstr1s = gstr1s.order("#{sort_column} #{sort_direction}")
      gstr1s = gstr1s.page(page).per(per_page)
    end 

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[voucher_id]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end
      def format_currency(amt)
      unit = @company.country.currency_code
      number_to_currency(amt, :unit => unit+" ", :precision=> 2)
    end

end
