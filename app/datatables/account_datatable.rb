class AccountDatatable
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
      :iTotalRecords => accounts.count,
      :iTotalDisplayRecords => accounts.total_count,
      :aaData => data
    }
  end

  private
    def data
      accounts.map do |account|
        [
          link_to(account.name, account_path(account)),
          link_to(account.account_head.name, account_head_path(account.account_head.id)),
          h(account.account_head.root.name),
          h(account.created_by_user),
          twitter_dropdown(account)
        ]
      end
    end

    def twitter_dropdown(account)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
          b.bootstrap_button "View", account_path(account),  :class => "btn btn-white btn-sm dropdown-toggle"
					#[FIXIT] This is poor design. Hardcoding the account name.
          b.link_to "View Ledger", "/account_books_and_registers/ledger?account_id=#{account.id}"
        if  account.erasable?
          b.link_to "Edit", edit_account_path(account)
          b.content_tag :li,"",:class => "divider"
          b.link_to "Delete", account, :method => "delete", :confirm =>"Are you sure?"
        end
      end
    end

    def accounts
      @accounts ||= fetch_accounts
    end

    def fetch_accounts
      if params[:sSearch].present?
        accounts = @company.accounts.where("accountable_type not in ('DutiesAndTaxesAccounts', 'SundryCreditor', 'SundryDebtor') and (name like :search or accountable_type like :search)", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present?
        accounts = search_accounts
      else
        accounts = @company.accounts.where("accountable_type not in ('DutiesAndTaxesAccounts', 'SundryCreditor', 'SundryDebtor')")
      end
      accounts = accounts.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

    def search_accounts
      results = Array.new
      results = @company.accounts.by_name(params[:sSearch_0]).by_group(params[:sSearch_1]).by_accountable_type(params[:sSearch_2]).by_creater(params[:sSearch_3])
      results
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[name account_head_id accountable_type created_by name]
      columns[params[:iSortCol_0].to_i]
    end

    def sort_direction
     params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end