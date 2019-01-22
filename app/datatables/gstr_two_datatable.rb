class GstrTwoDatatable
 include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  PURCHASE_CLASSIFICATION = { B2B: 0, B2BUR: 1, NIL: 6 }.with_indifferent_access
  GSTR_ADVANCE_RECEIPT_CLASSIFICATION = {INTRA: 7, INTER: 8}.with_indifferent_access 
  TYPE= {'1' => "B2BUR Purchase", '0' => "B2B Purchase", '6' => "NIL purchase", '4' => "INTRA" , '5' =>"INTER" }
  STATUS = {'0' => "Not Upoaded",'1' => "Uploaded", '2' => "Submitted", '3' => "Final"}

  def initialize(view, company, current_user, financial_year, gstr_two,type)
    @view =view
    @company=company
    @gstr_two = gstr_two
    @current_user = current_user
    @financial_year=financial_year
    @type = params[:type]

  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => gstr_two_items.count,
      :iTotalDisplayRecords => gstr_two_items.total_count,
      :aaData => data
    }
  end

  private
    def data
      if @type.eql?("CDNR")
          gstr_two_items.where(:voucher_type => 'GstDebitNote').map do |two_item|
                  debit_note =GstDebitNote.find_by_id(two_item.voucher_id)
                  [
                    link_to(debit_note.gst_debit_note_number, gst_debit_note_path(debit_note)),
                    (debit_note.customer_name),
                    h(debit_note.gst_debit_note_date.strftime("%d-%m-%Y")),
                    format_currency(debit_note.sub_total),
                    format_currency(debit_note.tax),
                    format_currency(debit_note.total_amount),
                    TYPE[two_item.voucher_classification.to_s],  
                    STATUS[two_item.status.to_s],
                    two_item.error_msg
                  ]

                end

      elsif @type.eql?("AP")
            gstr_two_items.where(:voucher_type => 'GstrAdvancePayment').map do |two_item|
                  gstr_advance_payment =GstrAdvancePayment.find_by_id(two_item.voucher_id)
                  [
                    link_to(gstr_advance_payment.voucher_number, gstr_advance_payment_path(gstr_advance_payment)),
                    (gstr_advance_payment.customer_name),
                    h(gstr_advance_payment.voucher_date.strftime("%d-%m-%Y")),
                    format_currency(gstr_advance_payment.sub_total),
                    format_currency(gstr_advance_payment.tax),
                    format_currency(gstr_advance_payment.amount),
                    TYPE[two_item.voucher_classification.to_s],  
                    STATUS[two_item.status.to_s],
                    two_item.error_msg
                  ]

                end


       elsif @type.eql?("B2B")

                gstr_two_items.where(:voucher_type => 'Purchase').map do |two_item|
                  purchase =Purchase.find_by_id(two_item.voucher_id)
                  [
                    link_to(purchase.purchase_number, purchase_path(purchase)),
                    (purchase.customer_name),
                    h(purchase.record_date.strftime("%d-%m-%Y")),
                    format_currency(purchase.sub_total),
                    format_currency(purchase.tax),
                    format_currency(purchase.total_amount),
                    TYPE[two_item.voucher_classification.to_s],  
                    STATUS[two_item.status.to_s],
                    two_item.error_msg
                  ]
                end

      elsif @type.eql?("B2BUR")

                gstr_two_items.where(:voucher_type => 'Purchase').map do |two_item|
                  purchase =Purchase.find_by_id(two_item.voucher_id)
                  [
                    link_to(purchase.purchase_number, purchase_path(purchase)),
                    (purchase.customer_name),
                    h(purchase.record_date.strftime("%d-%m-%Y")),
                    format_currency(purchase.sub_total),
                    format_currency(purchase.tax),
                    format_currency(purchase.total_amount),
                    TYPE[two_item.voucher_classification.to_s],  
                    STATUS[two_item.status.to_s],
                    two_item.error_msg
                  ]

                end

     elsif @type.eql?("NIL")

                gstr_two_items.where(:voucher_type => 'Purchase').map do |two_item|
                  purchase =Purchase.find_by_id(two_item.voucher_id)
                  [
                    link_to(purchase.purchase_number, purchase_path(purchase)),
                    (purchase.customer_name),
                    h(purchase.record_date.strftime("%d-%m-%Y")),
                    format_currency(purchase.sub_total),
                    format_currency(purchase.tax),
                    format_currency(purchase.total_amount),
                    TYPE[two_item.voucher_classification.to_s],  
                    STATUS[two_item.status.to_s],
                    two_item.error_msg
                  ]

                end

       elsif @type.eql?("EXPENSE")
                puts "@@@@@@@@@@in expnese "
                puts  gstr_two_items.where(:voucher_type =>'Expense').inspect
                gstr_two_items.where(:voucher_type => 'Expense').map do |two_item|
               
                  expense =Expense.find_by_id(two_item.voucher_id)
                  [
                    link_to(expense.voucher_number, expense_path(expense)),
                    (expense.customer_name),
                    h(expense.expense_date.strftime("%d-%m-%Y")),
                    format_currency(expense.sub_total),
                    format_currency(expense.tax),
                    format_currency(expense.total_amount),
                    TYPE[two_item.voucher_classification.to_s],  
                    STATUS[two_item.status.to_s],
                    two_item.error_msg
                  ]

                end

      else 

                gstr_two_items.where(:voucher_type => 'Purchase').map do |two_item|
                  
                  purchase =Purchase.find_by_id(two_item.voucher_id)
                  [
                    link_to(purchase.purchase_number, purchase_path(purchase)),
                    (purchase.customer_name),
                    h(purchase.record_date.strftime("%d-%m-%Y")),
                    format_currency(purchase.sub_total),
                    format_currency(purchase.tax),
                    format_currency(purchase.total_amount),
                    TYPE[two_item.voucher_classification.to_s],  
                    STATUS[two_item.status.to_s],
                    two_item.error_msg
                  ]
               


                end
        end
    end

    def gstr_two_items
      @gstr2s ||= fetch_items
    end


    def fetch_details

    end

    def fetch_items
      gstr2s = @gstr_two.fetch_items(@type)
      gstr2s = gstr2s.order("#{sort_column} #{sort_direction}")
      gstr2s = gstr2s.page(page).per(per_page)
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
