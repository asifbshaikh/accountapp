class ContactDetailsDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view)
    @view =view
  end


  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => contacts.count,
      :iTotalDisplayRecords => contacts.total_count,
      :aaData => data
    }
  end

  private
    def data
        contacts.map do |contact|
          [
            link_to(contact.full_name, admin_user_path(contact.id)),
            (contact.username),
            (contact.email),
            (contact.company.phone),
            link_to(contact.company.name, admin_company_path(contact.company.id)),
            (contact.created_at.to_date),
            (contact.company.plan.display_name),
            h(contact.company.subscription.status)
          ]
        end
    end

    def contacts
      @contacts ||= fetch_contacts
    end

    def fetch_contacts
        if params[:sSearch].present?
         contacts =  User.where(:deleted => false).joins({:company => :plan}, :roles).where("subscriptions.status like :search or roles.name like :search or plans.display_name like :search or users.first_name like :search or users.last_name like :search or users.username like :search or users.email like :search or users.last_login like :search or companies.name like :search ", :search => "%#{params[:sSearch]}%")
        else
        contacts = User.where(:deleted => false)
        end
      contacts = contacts.order("#{sort_column} #{sort_direction}")
      contacts = contacts.page(page).per(per_page)
    end

    # def search_contacts
    #   owner_array = Role.owner_list
    #   results = Array.new
    #   if !params[:sSearch_1].blank?
    #     results = Company.joins(:users=> :assignments).where("users.first_name like :search or users.last_name like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).where('assignments.role_id in (?)',owner_array).group("companies.id")
    #   elsif !params[:sSearch_3].blank?
    #     results = Company.joins(:users=> :assignments).where("users.email like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).where('assignments.role_id in (?)',owner_array).group("companies.id")
    #   else
    #   results = Company.by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).by_email(params[:sSearch_3]).group("companies.id")
    # end
    #   results
    # end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[last_login_time]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end