class AuditorsDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, company, user, financial_year)
    @view =view
    @company = company
    @user = user
    @financial_year = financial_year
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => auditors.count,
      :iTotalDisplayRecords => auditors.total_count,
      :aaData => data
    }
  end

  private

    def data
      auditors.map do |auditor|
        [
          auditor.full_name,
          auditor.username

        ]
      end
    end



    def auditors
      @auditors ||= fetch_auditors
    end

    def fetch_auditors
      if params[:sSearch].present?
        auditors = @company.auditors.where("name like :search or username like :search  or status like :search ", :search => "%#{params[:sSearch]}%")
      else
        auditors = @company.auditors
      end
      auditors.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
   end



    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[name username status  ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
     params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end