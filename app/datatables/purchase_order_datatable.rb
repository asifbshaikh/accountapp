class PurchaseOrderDatatable
	include Rails.application.routes.url_helpers
	include ActionView::Helpers
  include ActionView::Context
  include ApplicationHelper
	include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
	delegate :params, :h, :link_to, :number_to_currency, :to => :@view

	def initialize(view, company, user, financial_year)
	  @view =view
	  @company = company
	  @user=user
	  @financial_year = financial_year
	end

	def as_json(options ={})
	  {
	    :sEcho => params[:sEcho].to_i,
	    :iTotalRecords => purchase_orders.count,
	    :iTotalDisplayRecords => purchase_orders.total_count,
	    :aaData => data
	  }
	end

	private
	  def data
	  	if params[:vendor].present?
	  		purchase_orders.map do |purchase_order|
	  		  [
	  		    link_to(purchase_order.purchase_order_number, purchase_order_path(purchase_order)),
	  		    h(purchase_order.record_date),
	  		    "#{purchase_order.currency} #{format_amount(purchase_order.amount)}",
	  		    h(purchase_order.created_by_user),
	  		  ]
	  		end
	  	elsif params[:project].present?
	  		purchase_orders.map do |purchase_order|
	  		  [
	  		    link_to(purchase_order.purchase_order_number, purchase_order_path(purchase_order)),
	  		    h(purchase_order.account.name),
	  		    h(purchase_order.record_date),
	  		    "#{purchase_order.currency} #{format_amount(purchase_order.amount)}",
	  		    h(purchase_order.created_by_user),
	  		  ]
	  		end
	  	else
	  	data_arr=[]
        purchase_orders.each do |purchase_order|
        row=[]
        content=''
          content += content_tag :div, :class=>'modal fade', :id=>"modal#{purchase_order.id}" do
            @view.render(:partial=>"/purchase_orders/email_form.html.erb",:formats=>[:html],:locals=> {:purchase_order=>purchase_order})
          end

        content += link_to(purchase_order.purchase_order_number, purchase_order_path(purchase_order))
        row<<content
        row<<h(purchase_order.account.name)
        row<< h(purchase_order.record_date)
        row<< "#{purchase_order.currency} #{format_amount(purchase_order.amount)}"
        row<< h(purchase_order.created_by_user)
        row<< h(purchase_order.due_date)
      	row<< h(purchase_order.get_status)
        row<<twitter_dropdown(purchase_order)
        data_arr<<row
        end
         data_arr
		  end
	  end

	  def twitter_dropdown(purchase_order)
	    bootstrap_button_dropdown(:split => true, :button_options =>{:class=> "btn btn-white  dropdown-toggle btn-sm"}) do |b|
	        b.bootstrap_button "View", purchase_order_path(purchase_order),  :class => "btn btn-white  dropdown-toggle btn-sm"
	        b.link_to "Edit", edit_purchase_order_path(purchase_order) unless purchase_order.in_frozen_year? || purchase_order.purchased?
	        b.link_to "Export to PDF", purchase_order_path(purchase_order, :format => "pdf"), :target=>"_blank"
	        b.link_to "Email Voucher", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal#{purchase_order.id}" unless purchase_order.in_frozen_year?
	        b.content_tag :li,"",:class => "divider" unless purchase_order.in_frozen_year?
	        b.link_to "Convert To Purchase", {:controller => :purchases, :action => :po_to_purchase, :purchase_order_id => purchase_order.id} unless purchase_order.purchased?
	        b.link_to "Delete", purchase_order, :method => "delete", :confirm =>"Are you sure?"  unless purchase_order.in_frozen_year? || purchase_order.purchased?
	    end
	  end

	  def purchase_orders
	  	if params[:vendor].present?
	  		@purchase_orders ||= fetch_vendor_purchase_orders
	  	elsif params[:project].present?
	  		@purchase_orders ||= fetch_project_purchase_orders
	  	else
	    	@purchase_orders ||= fetch_purchase_orders
	    end
	  end
	  def fetch_vendor_purchase_orders
	  	if params[:sSearch].present?
	  	  purchase_orders = @company.purchase_orders.where("(purchase_order_number like :search or total_amount like :search) and account_id=#{params[:vendor].to_i}", :search => "%#{params[:sSearch]}%")
	  	elsif params[:sSearch_0].present?
	  	  purchase_orders = search_purchase_orders
	  	else
	  	  purchase_orders = @company.purchase_orders.where(:account_id=>params[:vendor].to_i).by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
	  	end
	  	purchase_orders.order("record_date DESC").page(page).per(per_page)
	  end

	  def fetch_project_purchase_orders
	  	if params[:sSearch].present?
	  	  purchase_orders = @company.purchase_orders.where("(purchase_order_number like :search or total_amount like :search) and project_id=#{params[:project].to_i}", :search => "%#{params[:sSearch]}%")
	  	elsif params[:sSearch_0].present?
	  	  purchase_orders = search_purchase_orders
	  	else
	  	  purchase_orders = @company.purchase_orders.by_project(params[:project]).by_branch_id(@user.branch_id).by_deleted(false)
	  	end
	  	Rails.logger.debug ("sorting by #{sort_column}")
	  	purchase_orders.order("record_date DESC").page(page).per(per_page)
	  end


	  def fetch_purchase_orders
	    if params[:sSearch].present?
	      search_params = "%#{params[:sSearch]}%"
	      @vendor_ids = Account.get_account_ids(@company,search_params)
	      @project_ids = Project.get_project_ids(@company,search_params)
	      @user_ids = User.get_user_ids(@company, search_params)
	      purchase_orders = @company.purchase_orders.where("purchase_order_number like ? or total_amount like ? or record_date like ? or account_id in (?) or created_by in (?)", search_params, search_params, search_params, @vendor_ids, @user_ids)
	    elsif params[:sSearch_0].present?
	      purchase_orders = search_purchase_orders
	    else
	      purchase_orders = @company.purchase_orders.by_branch_id(@user.branch_id).by_deleted(false)#.by_date(@financial_year)
	    end
	    Rails.logger.debug ("sorting by #{sort_column}")
	    purchase_orders.order("record_date DESC").page(page).per(per_page)
	  end

	  def search_purchase_orders
	    results = Array.new
	    if params[:sSearch_0].present?
	      # results = @company.customers.where("name like ?", "%#{params[:sSearch_0]}%")
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
	    columns = %w[id name created_by]
	    columns[params[:iSortCol_0].to_i]
	  end

	  def sort_direction
	    params[:sSortDir_0] == "desc" ? "asc" : "desc"
	  end

	  def format_currency(amt)
	    unit = @company.country.currency_code
	    number_to_currency(amt, :unit => unit+" ", :precision=> 2)
	  end
end