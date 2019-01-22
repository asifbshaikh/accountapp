class ProductDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include ActionView::Context
  # include ActionView::PartialRenderer
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  include ApplicationHelper

  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view, company)
    @view =view
    @company = company
    @inventoriable = @company.plan.is_inventoriable?
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => products.count,
      :iTotalDisplayRecords => products.total_count,
      :aaData => data
    }
  end


  private


    def data
      data_arr=[]
      products.each do |product|
        batches = PurchaseWarehouseDetail.get_hold_product_batches(@company.id, product.id)
        row=[]
        content=''
        if @inventoriable && product.batch_enable? && batches.size > 0
          content += content_tag :div, :class=>'modal fade', :id=>"modal-batch-details#{product.id}" do
            @view.render(:partial=>"products/batch_form.html.erb",:formats=>[:html],:locals=> {:product=>product, :row_index=>product.id})
          end
        end
        content += link_to(product.name, product_path(product))
        if @inventoriable && product.batch_enable? && batches.size > 0
          content += content_tag :div, :class=>"batch#{product.id}", :style=>'display:inline' do
            content_tag(:span, "#{batches.size} unallocate batches", :class=>'label bg-info')
          end
        end

        row<<content
        row<< product.product_code
        row << product.product_type
        if product.inventoriable?
          row<< content_tag(:span,"#{ format_amount(product.closing_stock)}", :class=>"qty#{product.id}")
        else
          row<< content_tag(:span,"Not Applicable", :class=>"qty#{product.id}")
        end
        row<< product.unit_of_measure
        row<< content_tag(:span, format_amount(product.sales_price), :class => "pull-right")
        row<< product.tag_list.join(', ')
        row<<twitter_dropdown(product, batches)
        data_arr<<row
      end
      data_arr
    end

    def twitter_dropdown(product, batches)
      bootstrap_button_dropdown( :button_options =>{:class=> "btn btn-white m-t-small btn-xs dropdown-toggle"}) do |b|
        b.bootstrap_button "Action", "#",  :class => "btn btn-white m-t-small btn-sm dropdown-toggle"
        b.link_to "View", product_path(product)
        b.link_to "Edit", edit_product_path(product)
        b.link_to "Delete", product, :method => "delete", :confirm =>"Are you sure?"
        if @inventoriable && product.batch_enable? && batches.size > 0
          b.link_to "Add batch details", "#", :"data-toggle"=>'modal', :"data-target"=>"#modal-batch-details#{product.id}", :class=>"batch-link#{product.id}"
        end
      end
    end

    def products
      @products ||= fetch_products
    end

    def fetch_products
      if params[:sSearch].present?
        products = @company.products.where("name like :search or type like :search or unit_of_measure like :search or reorder_level like :search ", :search=>"%#{params[:sSearch]}%")
      # elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
      #   invoices =  search_invoices
      else
        products = @company.products.where(:type => ['SalesItem', 'PurchaseItem', 'ResellerItem'])
      end
      products = products.order("name ASC")
      products = products.page(page).per(per_page)
    end

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[name]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end
