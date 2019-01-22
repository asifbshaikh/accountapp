class JournalsDatatable
  include Rails.application.routes.url_helpers 
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper
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
      :iTotalRecords => journals.count,
      :iTotalDisplayRecords => journals.total_count, 
      :aaData => data
    }
  end

  private

    def data
      if params[:project_id].present?
        journals.map do |journal|
          [
            link_to(journal.voucher_number, journal_path(journal)),
            h(journal.date),
            journal.voucher_against,
            content_tag(:span, format_amount(journal.total_amount), :class => "pull-right"),
            h(journal.created_by_user)
          ]
        end
      else
        journals.map do |journal|
          [
            link_to(journal.voucher_number, journal_path(journal)),
            h(journal.date),
            journal.voucher_against,
            content_tag(:span, format_amount(journal.total_amount), :class => "pull-right"),
            h(journal.created_by_user),
            h(journal.project_name),
            twitter_dropdown(journal)
          ]
        end
      end
    end
    

    def twitter_dropdown(journal)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
          b.bootstrap_button "View", journal_path(journal),  :class => "btn btn-white btn-sm dropdown-toggle"
          b.link_to "Edit", edit_journal_path(journal) unless journal.in_frozen_year?
          b.link_to "Export to PDF", journal_path(journal, :format => "pdf"), :target => "_blank"
          b.content_tag :li,"",:class => "divider" unless journal.in_frozen_year?
          b.link_to "Delete", journal, :method => "delete", :confirm =>"Are you sure?"  unless journal.in_frozen_year?
      end      
    end

    def journals
      if params[:project_id].present?
        @journals ||= fetch_project_journals
      else
        @journals ||= fetch_journals
      end
    end

    def fetch_journals
      if params[:sSearch].present?
        journals = @company.journals.where("voucher_number like :search or date like :search or total_amount like :search", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present?
        journals = search_journals
      else
        journals = @company.journals.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      journals.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

    def fetch_project_journals
      if params[:sSearch].present?
        journals = @company.journals.where("project_id=#{params[:project_id].to_i} and (voucher_number like :search or date like :search or total_amount like :search)", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present?
        journals = search_project_journals
      else
        journals = @company.journals.by_project(params[:project_id].to_i).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      journals.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
    end

   def search_journals

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.journals.maximum(:total_amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.journals.maximum(:total_amount)
      end
      begin
        results = @company.journals.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_to_account(params[:sSearch_2]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.journals.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_to_account(params[:sSearch_2])
      end
      results
    end

    def search_project_journals

       date_range=params[:sSearch_1].split("~")
       start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
       end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

       if !params[:sSearch_3].blank?
         amount_range=params[:sSearch_3].split("~")
         min_amt = amount_range[0].blank? ? 0 : amount_range[0]
         max_amt = amount_range[1].blank? ? (@company.journals.maximum(:total_amount)) : amount_range[1]
       else
         min_amt = 0
         max_amt = @company.journals.maximum(:total_amount)
       end
       begin
         results = @company.journals.by_project(params[:project_id].to_i).by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_to_account(params[:sSearch_2]).by_amount_range(min_amt, max_amt)
       rescue ArgumentError => e
         results = @company.journals.by_project(params[:project_id].to_i).by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_to_account(params[:sSearch_2])
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
      columns = %w[id date account_id total_amount created_by project_id ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end