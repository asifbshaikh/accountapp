class GstCreditNotesDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include GstCreditNotesHelper
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
      :iTotalRecords => gst_credit_notes.count,
      :iTotalDisplayRecords => gst_credit_notes.total_count,
      :aaData => data
    }
  end

  private

    def data
      gst_credit_notes.map do |gst_credit_note|
        [
          link_to(gst_credit_note.gst_credit_note_number, gst_credit_note_path(gst_credit_note)),
          h(gst_credit_note.gst_credit_note_date.strftime("%d-%m-%Y")),
          truncate(gst_credit_note.to_account_name, :length =>20),
          content_tag(:span, format_amount(gst_credit_note.amount), :class => "pull-right"),
          content_tag(:span, gst_credit_note.get_status, :size =>12, :class =>"label  #{gst_credit_note_status_badge gst_credit_note.get_status}"),
          twitter_dropdown(gst_credit_note)
        ]
      end
    end

    def twitter_dropdown(gst_credit_note)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
        b.bootstrap_button "View", gst_credit_note_path(gst_credit_note),  :class => "btn btn-white btn-sm dropdown-toggle"
        if gst_credit_note.status_id == 0
          b.link_to "Allocate amount", "/gst_credit_notes/allocate?id=#{gst_credit_note.id}"
        end
        b.link_to "Delete", gst_credit_note, :method => "delete", :confirm =>"Are you sure?"
      end
    end

    def gst_credit_notes
      @gst_credit_notes ||= fetch_gst_credit_notes
    end

    def fetch_gst_credit_notes
      if params[:sSearch].present?
        gst_credit_notes = @company.gst_credit_notes.where("gst_credit_note_number like :search or gst_credit_note_date like :search  or amount like :search or status_id like :search ", :search => "%#{params[:sSearch]}%")
      elsif  params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present?
        puts "bbbbbbbbbbbbbbbb#{params[:sSearch_0]}nnnn#{params[:sSearch_2]}llll#{params[:sSearch_3]}kkkk#{params[:sSearch_4]}hhh#{params[:sSearch_5]}"
        gst_credit_notes = search_gst_credit_notes
      else
        gst_credit_notes = @company.gst_credit_notes.by_branch_id(@user.branch_id)#.by_date(@financial_year)
      end
      gst_credit_notes.order("#{sort_column} #{sort_direction}").page(page).per(per_page)
   end


    def search_gst_credit_notes
      results = Array.new

      date_range=params[:sSearch_1].split("~")
      start_date = DataValidate.parsed_start_date(@financial_year, date_range[0])
      end_date = DataValidate.parsed_end_date(@financial_year, date_range[1])

      if !params[:sSearch_3].blank?
        amount_range=params[:sSearch_3].split("~")
        min_amt = amount_range[0].blank? ? 0 : amount_range[0]
        max_amt = amount_range[1].blank? ? (@company.gst_credit_notes.maximum(:amount)) : amount_range[1]
      else
        min_amt = 0
        max_amt = @company.gst_credit_notes.maximum(:amount)
      end
      begin
        results = @company.gst_credit_notes.by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_status(params[:sSearch_4]).by_to_account(params[:sSearch_2]).by_amount_range(min_amt, max_amt)
      rescue ArgumentError => e
        results = @company.gst_credit_notes.by_voucher(params[:sSearch_0]).by_date_range(start_date, end_date).by_status(params[:sSearch_4]).by_to_account(params[:sSearch_2])
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
      columns = %w[gst_credit_note_number gst_credit_note_date from_account_id to_account_id amount  ]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end