class CompanyDatatable
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
      :iTotalRecords => companies.count,
      :iTotalDisplayRecords => companies.total_count,
      :aaData => data
    }
  end

  private
    def data
        companies.map do |company|
          [
            link_to(company.name, admin_company_path(company.id)),
            (company.plan.display_name),
            (company.users.first.full_name),
            (company.users.first.email),
            (company.activation_date.strftime("%d-%m-%Y")),
            h(company.subscription.renewal_date.to_date),
            h(company.subscription.amount)
          ]
        end
    end

    def companies
      @companies ||= fetch_companies
    end

    def fetch_companies
      if params[:tab_ref] == "all_companies"
        if params[:sSearch].present?
          owner_array = Role.owner_list
          companies =  Company.joins(:subscription).
            where('companies.name like :search or companies.phone like :search or companies.email like :search', :search => "%#{params[:sSearch]}%").
            order("companies.activation_date desc").includes(:user)
        elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present?
          companies = search_companies.order("activation_date desc")
        else
          companies = Company.where(:deleted => false).joins(:subscription).where(:subscriptions => {status: ["Paid"]}).order("created_at desc").includes(:users, :plan)
        end
      elsif params[:tab_ref] == "expiring_this_month"
        if params[:sSearch].present?
          start_date = Time.zone.now.to_date.beginning_of_month
          end_date = start_date.advance(:months => 3)
          companies = Company.joins(:subscription)
            .where("subscriptions.renewal_date between ? and ? and subscriptions.plan_id !=8", start_date, end_date)
            .where('companies.name like :search or companies.phone like :search or companies.email like :search', :search => "%#{params[:sSearch]}%")
            .order("subscriptions.renewal_date asc")
        else
          companies = Company.expiring_this_month.order("created_at desc")
        end
      elsif params[:tab_ref] == "expired_companies"
        if params[:sSearch].present?
          owner_array = Role.owner_list
          companies = Company.joins(:subscription)
            .where("subscriptions.renewal_date < ?", Time.zone.now.to_date)
            .where('companies.name like :search or companies.phone like :search or companies.email like :search', :search => "%#{params[:sSearch]}%")
            .group("companies.id")
            .order("activation_date desc")
          # elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present?
          #   companies =  search_companies.order("activation_date desc")
        else
          companies = Company.expired_companies.order("created_at desc")
        end
      elsif params[:tab_ref] == "paid_companies"
        if params[:sSearch].present?
          companies = Company.joins(:subscription)
            .where("subscriptions.status = ?","Paid")
            .where('companies.name like :search or companies.phone like :search or companies.email like :search', :search => "%#{params[:sSearch]}%")
            .group("companies.id")
            .order("activation_date desc")
        else
          companies = Company.joins(:subscription).where("subscriptions.status = ?","Paid").order("created_at desc").includes(:plan, :users)
        end
      elsif params[:tab_ref] == "paid_expiring_this_month"
        if params[:sSearch].present?
          companies = Company.joins({:users=> :assignments}, :plan,:subscription)
            .where("subscriptions.status = ? and subscriptions.renewal_date between ? and ? ","Paid",Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date.end_of_month)
            .where('companies.name like :search or companies.phone like :search or companies.email like :search', :search => "%#{params[:sSearch]}%")
            .group("companies.id")
            .order("activation_date desc")
        else
          companies = Company.joins(:subscription).where("subscriptions.status = ? and subscriptions.renewal_date between ? and ? ","Paid",Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date.end_of_month).order("created_at desc")
        end
      elsif params[:tab_ref] == "paid_expired_companies"
        if params[:sSearch].present?
          owner_array = Role.owner_list
          companies = Company.joins(:subscription)
            .where("subscriptions.status = ? and subscriptions.renewal_date < ? ","Paid",Time.zone.now.to_date)
            .where('companies.name like :search or companies.phone like :search or companies.email like :search', :search => "%#{params[:sSearch]}%")
            .group("companies.id")
            .order("activation_date desc")
        else
          companies = Company.joins(:subscription).where("subscriptions.status = ? and subscriptions.renewal_date < ? ","Paid",Time.zone.now.to_date).order("created_at desc")
        end
      end
      # companies = companies.order("#{sort_column} #{sort_direction}")
      companies = companies.page(page).per(per_page)
    end

    def search_companies
      owner_array = Role.owner_list
      results = Array.new
      if !params[:sSearch_1].blank?
        results = Company.joins(:users=> :assignments).where("users.first_name like :search or users.last_name like :search", :search=> "%#{params[:sSearch_1]}%")
          .by_name(params[:sSearch_0]).by_contact(params[:sSearch_2])
          .where('assignments.role_id in (?)',owner_array).group("companies.id")
      elsif !params[:sSearch_3].blank?
        results = Company.joins(:users=> :assignments).where("users.email like :search", :search=> "%#{params[:sSearch_3]}%").where('assignments.role_id in (?)',owner_array).group("companies.id")
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
      if params[:tab_ref] == "all_companies" || params[:tab_ref] == "regs_this_month" || params[:tab_ref] == "expiring_this_month"
        columns = %w[activation_date]
      else
        columns = %w[created_at]
      end
      columns
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

  end
