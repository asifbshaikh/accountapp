class ExpenseDatatable
	include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper
  include ExpensesHelper


  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, company, user, financial_year)
    @view=view
    @company=company
    @user=user
    @financial_year=financial_year
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => expenses.count,
      :iTotalDisplayRecords => expenses.total_count,
      :aaData => data
    }
  end

  private

  def data
    if params[:project].present?
      expenses.map do |expense|
        [
          link_to(expense.voucher_number, expense_path(expense)),
          expense.vendor_name,
          h(expense.expense_date),
          "<span class='pull-right'>#{format_amt_with_currency(expense.currency, expense.total_amount)}</span>",
          expense.created_by_user
        ]
      end
    else
      expenses.map do |expense|
        [
          link_to(expense.voucher_number, expense_path(expense)),
         if !expense.expense_line_items.blank?
          h(expense.expense_line_items[0].account.name)
        end,
          h(expense.expense_date),
          link_to(expense.vendor_name, account_path(expense.account_id)),
          "<span class='pull-right'>#{format_amt_with_currency(expense.currency, expense.total_amount)}</span>",
          expense.created_by_user,
          content_tag(:span, expense.status, :class => "label #{expense_status_badge expense.status}"),
          twitter_dropdown(expense)
        ]
      end
    end
  end

def twitter_dropdown(expense)
  bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
    b.bootstrap_button "View", expense_path(expense),  :class => "btn btn-white btn-sm dropdown-toggle"
    b.link_to "Edit", edit_expense_path(expense) unless expense.in_frozen_year?
    b.link_to "Export to PDF", expense_path(expense, :format => "pdf"), :target => "_blank"
    b.content_tag :li,"",:class => "divider" unless expense.in_frozen_year?
    b.link_to "Delete", expense, :method => "delete", :confirm =>"Are you sure?" unless expense.in_frozen_year?
  end
end

def expenses
  if params[:project].present?
    @expenses ||= fetch_project_expenses
  else
   @expenses ||= fetch_expenses
 end
end

def fetch_expenses
  if params[:sSearch].present?
    search_params = "%#{params[:sSearch]}%"
    @from_account_ids = Account.get_account_ids(@company,search_params)
    @project_ids = Project.get_project_ids(@company,search_params)
    @user_ids = User.get_user_ids(@company,search_params)
    expenses = @company.expenses.where("voucher_number like ? or expense_date like ? or total_amount like ? or account_id in (?) or project_id in (?) or created_by in (?)", search_params, search_params, search_params, @from_account_ids, @project_ids, @user_ids)
  elsif params[:sSearch_0].present? || params[:sSearch_1].present?  ||
    (params[:sSearch_2].present? && params[:sSearch_2]!='~') || params[:sSearch_3].present? || params[:sSearch_4].present? || (params[:sSearch_5].present? && params[:sSearch_5]!='~' )
    expenses = search_expenses
  else
      expenses = @company.expenses.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
    end
    expenses = expenses.order("#{sort_column} #{sort_direction}")
    expenses = expenses.page(page).per(per_page)
    expenses
  end

  def fetch_project_expenses
    if params[:sSearch].present?
      expenses = @company.expenses.where("voucher_number like :search or expense_date like :search and project_id = #{params[:project].to_i}", :search => "%#{params[:sSearch]}%")
    else
      expenses = @company.expenses.by_project(params[:project]).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
    end
    expenses = expenses.order("#{sort_column} #{sort_direction}")
    expenses = expenses.page(page).per(per_page)
    expenses
  end

  def search_expenses
    results = Array.new

    date_range=params[:sSearch_2].split("~")
    start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
    end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

    if !params[:sSearch_5].blank?
      amount_range=params[:sSearch_5].split("~")
      min_amt = amount_range[0].blank? ? 0 : amount_range[0]
      max_amt = amount_range[1].blank? ? (@company.purchases.maximum(:total_amount)) : amount_range[1]
    else
      min_amt = 0
      max_amt = @company.expenses.maximum(:total_amount)
    end
    begin
      if !params[:sSearch_4].blank?
        results = @company.expenses.joins(:expense_line_items).where("expense_line_items.account_id = ?",params[:sSearch_4]).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_1]).by_project(params[:sSearch_3]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
      else
        results = @company.expenses.by_deleted(false).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_1]).by_project(params[:sSearch_3]).by_date_range(start_date, end_date).by_amount_range(min_amt, max_amt)
      end
    rescue ArgumentError => e
      results = @company.expenses.by_deleted(false).by_voucher(params[:sSearch_0]).by_account(params[:sSearch_1]).by_project(params[:sSearch_3]).by_date_range(start_date, end_date)
    end
    results
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id id expense_date account_id total_amount created_by status_id ]
     sort_col_index=params[:iSortCol_0].to_i

     if sort_col_index >= columns.size
        sort_col_index=0
      end
      columns[sort_col_index]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "asc" : "desc"
  end
end
