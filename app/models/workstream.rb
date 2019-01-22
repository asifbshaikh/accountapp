class Workstream < ActiveRecord::Base

  #.page(page).per(per_page)
#  default_scope order('action_time DESC')
  scope :by_branch_id, lambda {|id| includes(:user).where(:branch_id => id) unless id.blank? }
  scope :by_search, lambda{|search| includes(:user).where("action like :search or action_time like :search or action_code like :search", :search => "%#{search}%")}
  scope :by_date, lambda{|fin_year| includes(:user).where(:created_at => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}

  belongs_to :company
  belongs_to :user

  class << self

    #
    # Returns the activities performed for a company based on the user rights and search string.
    # ==== Attributes
    # * +company+ - The company for which the activities need to be retrieved.
    # * +user+ - The user of the company requesting the data. If the user is owner or
    #            NOT associated with a branch, all data across branches is retrieved.
    #            If the User is associated with a branch only the branch workstreams are retrieved.
    # * +options+ - Optional parameters are :sSearch that contains the search value.
    #                page - the size of page for pagination
    #
    def company_workstreams(company, user, search={})
      if search[:sSearch].present?
        value = substitute_search(search[:sSearch])
        if user.on_branch?
          company.workstreams.by_branch_id(user.branch_id).by_search(value).order('action_time DESC').page(search[:page]).per(search[:per_page])
        elsif !search[:userid].nil?
            company.workstreams.where("workstreams.user_id=?",search[:userid]).by_branch_id(user.branch_id).by_search(value).order('action_time DESC').page(search[:page]).per(search[:per_page])
        else
          company.workstreams.by_search(value).order('action_time DESC').page(search[:page]).per(search[:per_page])
        end

      else
        if user.on_branch?
          company.workstreams.by_branch_id(user.branch_id).order('action_time DESC').page(search[:page]).per(search[:per_page])
        elsif !search[:userid].nil?
            company.workstreams.where("workstreams.user_id=?",search[:userid]).by_branch_id(user.branch_id).by_search(value).order('action_time DESC').page(search[:page]).per(search[:per_page])
        else
          company.workstreams.includes(:user).order('action_time DESC').page(search[:page]).per(search[:per_page])
        end
      end
    end

    #[TODO] Find out from where is this method being called. Remove if not required.
    def admin_workstreams(company, user, search={})
      if search[:sSearch].present?
        value = substitute_search(search[:sSearch])
        company.workstreams.by_search(value).page(search[:page]).per(search[:per_page])
      else
        company.workstreams.includes(:user).page(search[:page]).per(search[:per_page])
      end
    end

    def all_workstreams(search={})
      if search[:sSearch].present?
        value = substitute_search(search[:sSearch])
        workstreams.by_search(value).page(search[:page]).per(search[:per_page])
      else
        workstreams.includes(:user).page(search[:page]).per(search[:per_page])
      end
    end

    def substitute_search(search_value)
      if /added|Added/i.match(search_value)
        "created"
      else
        search_value
      end
    end

    #[TODO] Add optional parameters for project, customer and vendor
    def register_user_action(company_id, user_id, user_remote_ip, action, action_code, branch_id)
      workstream = Workstream.new
      workstream.company_id = company_id
      workstream.user_id = user_id
      workstream.action_time = Time.zone.now
      workstream.IP_address = user_remote_ip
      workstream.action = action
      workstream.action_code = action_code
      workstream.branch_id = branch_id
      workstream.save
    end

    #
    # Returns the last 5 activities performed by a user.
    # ==== Attributes
    # * +company+ - The company for which the activities need to be retrieved.
    # * +user+ - The user of the company requesting the data.
    #
    # If the user's role is owner then latest 5 activities of all users
    # of that company are returned.
    #
    def recent_five(company, user)
     if !user.auditor?
      if user.owner?
        includes(:user).where(:company_id => company.id).limit(5).order(" action_time DESC")
      elsif user.on_branch?
        includes(:user).where(:company_id => company.id, :user_id => user.id, :branch_id => user.branch_id).limit(5).order(" action_time DESC")
      else
        includes(:user).where(:company_id => company.id, :user_id => user.id).limit(5).order(" action_time DESC")
      end
     end
    end

  end #class end

end
