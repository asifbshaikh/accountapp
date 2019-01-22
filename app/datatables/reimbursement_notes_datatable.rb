class ReimbursementNotesDatatable
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
      :iTotalRecords => reimbursement_notes.count,
      :iTotalDisplayRecords => reimbursement_notes.total_count,
      :aaData => data
    }
  end

  private

    def data
      reimbursement_notes.map do |reimbursement_note|
        [
          link_to(reimbursement_note.reimbursement_note_number, reimbursement_note_path(reimbursement_note)),
          h(reimbursement_note.transaction_date.strftime("%d-%m-%Y")),
          truncate(reimbursement_note.from_account_id.blank? ? "" : Account.find(reimbursement_note.from_account_id).name, :length =>20),
          content_tag(:span, format_amount(reimbursement_note.amount), :class => "pull-right"),
          content_tag(:span, reimbursement_note.get_status, :class => "#{reimbursement_note.get_badge(reimbursement_note.get_status)}"),
          twitter_dropdown(reimbursement_note)
        ]
      end
    end


    def twitter_dropdown(reimbursement_note)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", reimbursement_note_path(reimbursement_note),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Edit", edit_reimbursement_note_path(reimbursement_note) unless reimbursement_note.in_frozen_year? || reimbursement_note.reimbursement_voucher_id.present?
        b.link_to "Print PDF", reimbursement_note_path(reimbursement_note, :format => 'pdf')
        b.link_to "Delete", reimbursement_note, :method => "delete", :confirm =>"Are you sure?"  unless reimbursement_note.in_frozen_year? || reimbursement_note.reimbursement_voucher_id.present?
      end
    end

    def reimbursement_notes
      @reimbursement_notes ||= fetch_reimbursement_notes
    end

    def fetch_reimbursement_notes
      if params[:sSearch].present?
        reimbursement_notes = @company.reimbursement_notes.where("reimbursement_note_number like :search or transaction_date like :search  or amount like :search ", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present?
        reimbursement_notes = search_reimbursement_notes
      else
        reimbursement_notes = @company.reimbursement_notes.by_branch_id(@user.branch_id).by_deleted(false)
        # reimbursement_notes = @company.reimbursement_notes.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      reimbursement_notes.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
   end


    def search_reimbursement_notes
      results = Array.new

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_4].blank?
        amount_range=params[:sSearch_4].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.reimbursement_notes.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.reimbursement_notes.maximum(:amount)
      end
      begin
        results = @company.reimbursement_notes.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.reimbursement_notes.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2])
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
      columns = %w[reimbursement_note_number transaction_date from_account_id amount]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end
end
