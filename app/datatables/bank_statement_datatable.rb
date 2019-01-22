class BankStatementDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view,company)
    @view =view
    @company = company
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => bank_statements.count,
      :iTotalDisplayRecords => bank_statements.total_count,
      :aaData => data
    }
  end
  private
    def data
       bank_statements.map do |statement|

          [
            link_to("#{statement.file_file_name}", bank_statement_path(statement.id)),
            (statement.start_date.to_date),
            (statement.end_date.to_date),
            h(statement.get_account_name(statement.account_id).name)
          ]

      end
    end

    def bank_statements
      @bank_statements ||= fetch_bank_statements
    end

    def fetch_bank_statements
      bank_statements = BankStatement.where(:company_id => @company.id)
      bank_statements = bank_statements.order("#{sort_column} #{sort_direction}")
      bank_statements = bank_statements.page(page).per(per_page)
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