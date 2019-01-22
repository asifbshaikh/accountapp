class ExpiringThisMonthDatatable
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
      :iTotalRecords => exps_month.count,
      :iTotalDisplayRecords => exps_month.total_count,
      :aaData => data
    }
  end

  private
    def data
       exps_month.map do |company|
          [
            link_to(company.name, admin_company_path(company.id)),
            (company.plan.display_name),
            (company.users.first.full_name),
            (Company.find_last_contact_date(company.id) unless Company.find_last_contact_date(company.id).blank?),
            (Company.find_next_contact_date(company.id) unless Company.find_next_contact_date(company.id).blank?),
            (company.users.first.email),
            (company.activation_date.strftime("%d-%m-%Y")),
            h(company.subscription.renewal_date.to_date)
          ]
      end
    end

    def find_customer_relationship(company)
      customer_relationship = CustomerRelationship.find_by_id(company)
      if !customer_relationship.blank?
      customer_relationship.last.last_contact_date.strftime("%d-%m-%Y") unless customer_relationship.blank?
    end
    end

    def companies
      @companies ||= fetch_companies
    end

    def fetch_companies
      if params[:sSearch].present?

          # companies = Company.where("name like :search or phone like :search or email like :search or activation_date like :search ", :search => "%#{params[:sSearch]}%")
         owner_array = Role.owner_list
         companies =  Company.joins({:users=> :assignments}, :plan).where('plans.display_name like :search or companies.name like :search or companies.phone like :search or companies.email like :search or users.email like :search or users.first_name like :search or users.last_name like :search', :search => "%#{params[:sSearch]}%").where('assignments.role_id in (?)',owner_array).group("companies.id")

      elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present?
        companies =  search_companies
      else
        companies = Company.expiring_this_month
      end
      companies = companies.order("#{sort_column} #{sort_direction}")
      companies = companies.page(page).per(per_page)
    end

    def search_companies
      owner_array = Role.owner_list
      results = Array.new
      if !params[:sSearch_1].blank?
        results = Company.joins(:users=> :assignments).where("users.first_name like :search or users.last_name like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).where('assignments.role_id in (?)',owner_array).group("companies.id")
      elsif !params[:sSearch_3].blank?
        results = Company.joins(:users=> :assignments).where("users.email like :search", :search=> "%#{params[:sSearch_1]}%").by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).where('assignments.role_id in (?)',owner_array).group("companies.id")
      else
      results = Company.by_name(params[:sSearch_0]).by_contact(params[:sSearch_2]).by_email(params[:sSearch_3]).group("companies.id")
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
      columns = %w[activation_date]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end