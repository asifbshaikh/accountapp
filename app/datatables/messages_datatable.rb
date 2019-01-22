class MessagesDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, company, user)
    @view =view
    @company = company
    @user = user
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => messages.count,
      :iTotalDisplayRecords => messages.total_count,
      :aaData => data
    }
  end

  private

    def data
      messages.map do |message|
        [
         link_to(truncate(message.subject, :length =>20), message_path(message)),
          truncate(message.description, :length => 20),
          h(message.created_at),
          message.from,
          twitter_dropdown(message)
        ]
      end
    end


    def twitter_dropdown(message)
      bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white btn-sm dropdown-toggle"}) do |b|
          b.bootstrap_button "View",message_path(message),  :class => "btn btn-white btn-sm dropdown-toggle"
          if message.can_delete? @user.id
          b.link_to "Delete", message, :method => "delete", :confirm =>"Are you sure?"
          end
      end
    end

    def messages
      if params[:sent].present?
       @messages ||= fetch_sent_messages
      else
       @messages ||= fetch_messages
      end

    end

    def fetch_messages
      if params[:sSearch].present?
        #@company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(current_financial_year).search(params[:search])
        messages = @company.messages.where("subject like :search or description like :search or created_at like :search", :search => "%#{params[:sSearch]}%")
      else
        messages = Message.received_messages(@company.id, @user.id)
      end
      messages = messages.order("#{sort_column} #{sort_direction}")
      messages = messages.page(page).per(per_page)
      messages
    end
    def fetch_sent_messages
      if params[:sSearch].present?
        #@company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_date(current_financial_year).search(params[:search])
        messages = @company.messages.where("subject like :search or description like :search or created_at like :search", :search => "%#{params[:sSearch]}%")
      else
        messages = Message.sent_messages(@company.id, @user.id)
      end
      messages = messages.order("#{sort_column} #{sort_direction}")
      messages = messages.page(page).per(per_page)
      messages
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[subject description from created_at]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end


end