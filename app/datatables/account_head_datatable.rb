class AccountHeadDatatable
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
      :iTotalRecords => account_heads.count,
      :iTotalDisplayRecords => account_heads.total_count,
      :aaData => data
    }
  end

  private
    def data
      account_heads.map do |account_head|
        [
          link_to(account_head.name, account_head_path(account_head)),
          account_head.parent_name,
          h(account_head.created_by_user),
          twitter_dropdown(account_head)
        ]
      end
    end

    def twitter_dropdown(account_head)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
          b.bootstrap_button "View", account_head_path(account_head),  :class => "btn btn-white btn-sm dropdown-toggle"
          b.link_to "Create sub group", new_account_head_path(:parent_id=> account_head.id)
          if account_head.erasable?
            b.link_to "Edit", edit_account_head_path(account_head)
            b.content_tag :li,"",:class => "divider"
            b.link_to "Delete", account_head, :method => "delete", :confirm =>"Are you sure?"
          end
      end
    end

    def account_heads
      @account_heads ||= fetch_account_heads
    end

    def fetch_account_heads
      if params[:sSearch].present?
        account_heads = @company.account_heads.where("name like :search", :search => "%#{params[:sSearch]}%").exclude_parties
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present?
        account_heads = search_account_heads
      else
        account_heads = @company.account_heads.where(:deleted => false).exclude_parties
      end
      account_heads.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

    def search_account_heads
      results = Array.new
      results = @company.account_heads.by_name(params[:sSearch_0]).by_parent(params[:sSearch_1]).by_creater(params[:sSearch_2]).exclude_parties
      results
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[name parent_id created_by name]
      columns[params[:iSortCol_0].to_i]
    end

    def sort_direction
     params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end