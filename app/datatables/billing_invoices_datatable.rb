class BillingInvoicesDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view)
    @view =view
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => bill_invoices.count,
      :iTotalDisplayRecords => bill_invoices.total_count,
      :aaData => data
    }
  end

  private
    def data
       bill_invoices.map do |invoice|
          [
            link_to(invoice.company.name, admin_billing_invoice_path(invoice.id)),
            (invoice.company.name),
            (invoice.invoice_date.to_date),
            h(invoice.amount)

          ]

      end
    end


    def bill_invoices
      @bill_invoices ||= fetch_bill_invoices
    end

    def fetch_bill_invoices
      if params[:sSearch].present?

          # companies = Company.where("name like :search or phone like :search or email like :search or activation_date like :search ", :search => "%#{params[:sSearch]}%")
         bill_invoices =  BillingInvoice.joins(:companies).where('bill_invoices.invoice_number like :search or bill_invoices.invoice_date like :search or bill_invoices.amount like :search or companies.name like :search', :search => "%#{params[:sSearch]}%")

      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present?
        bill_invoices =  search_bill_invoices
      else
        bill_invoices = BillingInvoice.all
      end
      bill_invoices = bill_invoices.order("#{sort_column} #{sort_direction}")
      bill_invoices = bill_invoices.page(page).per(per_page)
    end

    def search_bill_invoices
    #   owner_array = Role.owner_list
    #   results = Array.new
    #   if !params[:sSearch_1].blank?
    #     results = Company.joins(:users=> :assignments).where("users.first_name like :search or users.last_name like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).by_email(params[:sSearch_3]).where('assignments.role_id in (?)',owner_array)
    #   else
    #   results = Company.by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).by_email(params[:sSearch_3])
    # end
    #   results
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[created_at]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end