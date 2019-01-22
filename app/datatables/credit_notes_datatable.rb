class CreditNotesDatatable
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
      :iTotalRecords => credit_notes.count,
      :iTotalDisplayRecords => credit_notes.total_count,
      :aaData => data
    }
  end

  private

    def data
      credit_notes.map do |credit_note|
        [
          link_to(credit_note.credit_note_number, credit_note_path(credit_note)),
          h(credit_note.transaction_date.strftime("%d-%m-%Y")),
          truncate(credit_note.from_account_name, :length =>20),
          truncate(credit_note.to_account_name, :length =>20),
          content_tag(:span, format_amount(credit_note.amount), :class => "pull-right"),
          twitter_dropdown(credit_note)
        ]
      end
    end


    def twitter_dropdown(credit_note)
      send("#{CreditNote::READ_ONLY[credit_note.read_only?]}_action_dropdown", credit_note)
    end

    def read_only_action_dropdown(credit_note)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", credit_note_path(credit_note),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Allocate amount", "/credit_notes/allocate?id=#{credit_note.id}"
      end
    end

    def read_write_action_dropdown(credit_note)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", credit_note_path(credit_note),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Allocate amount", "/credit_notes/allocate?id=#{credit_note.id}"
        b.link_to "Edit", credit_note unless credit_note.in_frozen_year?
        b.link_to "Delete", credit_note, :method => "delete", :confirm =>"Are you sure?"
      end
    end

    def credit_notes
      @credit_notes ||= fetch_credit_notes
    end

    def fetch_credit_notes
      if params[:sSearch].present?
        credit_notes = @company.credit_notes.where("credit_note_number like :search or transaction_date like :search  or amount like :search ", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present?
        credit_notes = search_credit_notes
      else
        credit_notes = @company.credit_notes.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      credit_notes.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
   end


    def search_credit_notes
      results = Array.new

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_4].blank?
        amount_range=params[:sSearch_4].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.credit_notes.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.credit_notes.maximum(:amount)
      end
      begin
        results = @company.credit_notes.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_to_account(params[:sSearch_3]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.credit_notes.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_to_account(params[:sSearch_3])
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
      columns = %w[credit_note_number transaction_date from_account_id to_account_id amount  ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end