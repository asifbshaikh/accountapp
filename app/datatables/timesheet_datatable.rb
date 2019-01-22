class TimesheetDatatable
	include Rails.application.routes.url_helpers 
	include ActionView::Helpers
	include ActionView::Context
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
	    :iTotalRecords => timesheets.count,
	    :iTotalDisplayRecords => timesheets.total_count, 
	    :aaData => data
	  }
	end

	private
	def data
		if params[:project].present?
			timesheets.map do |timesheet|
				[
				link_to(timesheet.record_date, timesheet_path(timesheet)),
				h(timesheet.time_spent_on_project(params[:project])),
				h(timesheet.user.full_name)
			  ]
			end
		else

		end
	end

	def timesheets
		if params[:project].present?
			@timesheets ||= fetch_project_timesheets
		else
			@timesheets ||= fetch_timesheets
		end
	end

	def fetch_project_timesheets
		if params[:sSearch].present?
			users = @company.users.where("first_name like :search of last_name like :search", :search=>"%#{params[:sSearch]}%")
			timesheets=@company.timesheets.where("record_date like :search or user_id in (#{users.map{ |user| user.id  }})",:search=>"%#{params[:sSearch]}%")
		else
			timesheets=@company.timesheets.by_project(params[:project])
		end
		timesheets = timesheets.order("#{sort_column} #{sort_direction}")
		timesheets = timesheets.page(page).per(per_page)
	end

	def fetch_timesheets
		
	end

	def page
	  params[:iDisplayStart].to_i / per_page + 1
	end

	def per_page
	  params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
	end

	def sort_column
	  columns = %w[record_date timestamp user_id]
	  columns[params[:isortCol_0].to_i]
	end

	def sort_direction
	  params[:sSortDir_0] == "desc" ? "asc" : "desc"
	end
end