class DebitNotesDatatable
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
      :iTotalRecords => debit_notes.count,
      :iTotalDisplayRecords => debit_notes.total_count,
      :aaData => data
    }
  end

  private

    def data
      debit_notes.map do |debit_note|
        [
          link_to(debit_note.debit_note_number, debit_note_path(debit_note)),
          h(debit_note.transaction_date.strftime("%d-%m-%Y")),
          truncate(debit_note.from_account_id.blank? ? "" : Account.find(debit_note.from_account_id).name, :length =>20),
          truncate(Account.find(debit_note.to_account_id).name, :length =>20),
          content_tag(:span, format_amount(debit_note.amount), :class => "pull-right"),
          twitter_dropdown(debit_note)
        ]
      end
    end


    def twitter_dropdown(debit_note)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", debit_note_path(debit_note),  :class => "btn btn-white btn-sm dropdown-toggle"
        b.link_to "Allocate amount", "/debit_notes/allocate?id=#{debit_note.id}" if debit_note.allocation_enable?
        b.link_to "Edit", debit_note unless debit_note.in_frozen_year? || debit_note.read_only
        b.link_to "Delete", debit_note, :method => "delete", :confirm =>"Are you sure?"  unless debit_note.in_frozen_year? || debit_note.read_only
      end
    end

    def debit_notes
      @debit_notes ||= fetch_debit_notes
    end

    def fetch_debit_notes
      if params[:sSearch].present?
        debit_notes = @company.debit_notes.where("debit_note_number like :search or transaction_date like :search  or amount like :search ", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present?
        debit_notes = search_debit_notes
      else
        debit_notes = @company.debit_notes.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
      end
      debit_notes.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
   end


    def search_debit_notes
      results = Array.new

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_4].blank?
        amount_range=params[:sSearch_4].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.debit_notes.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.debit_notes.maximum(:amount)
      end
      begin
        results = @company.debit_notes.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_to_account(params[:sSearch_3]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.debit_notes.by_deleted(false).by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_from_account(params[:sSearch_2]).by_to_account(params[:sSearch_3])
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
      columns = %w[debit_note_number transaction_date from_account_id to_account_id amount  ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end