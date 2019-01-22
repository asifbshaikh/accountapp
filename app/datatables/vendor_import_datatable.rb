class VendorImportDatatable
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include Twitter::Bootstrap::Markup::Rails::Helpers::ButtonHelpers
  delegate :params, :h, :link_to, :number_to_currency, :to => :@view

  def initialize(view,company)
    @view =view
    @company = company
  end

  def as_json(options ={})
    {
      :sEcho => params[:sEcho].to_i,
      :iTotalRecords => vendor_imports.count,
      :iTotalDisplayRecords => vendor_imports.total_count,
      :aaData => data
    }
  end
  private
    def data
       vendor_imports.map do |file|

          [
            link_to(file.file_file_name, :controller => "vendor_imports",:action => "import_preview",:file_id => file.id),
            h(file.created_at.to_date)
          ]

      end
    end

    def find_user(user_id)
      user = User.find(user_id).full_name
    end

    def vendor_imports
      @vendor_imports ||= fetch_vendor_imports
    end

    def fetch_vendor_imports
      vendor_imports = ImportFile.where(:company_id => @company.id, :item_type => 4)
      vendor_imports = vendor_imports.order("#{sort_column} #{sort_direction}")
      vendor_imports = vendor_imports.page(page).per(per_page)
    end


    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[created_at]
      columns[params[:isortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "asc" : "desc"
    end

end