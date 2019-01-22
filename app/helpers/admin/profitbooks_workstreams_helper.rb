module Admin::ProfitbooksWorkstreamsHelper


  def product_update_link(product_update)
    if product_update.link_URL?
      content_tag :p do
        raw "For more details, please visit : <a href=#{product_update.link_URL} target='_blank'>#{product_update.link_URL}</a>&nbsp;<i class='icon-share'></i></p>"
      end
    end
  end

  def product_update_edit_button(product_update)
    link_to("Edit", edit_admin_profitbooks_workstream_path(product_update), :class => "btn btn-success btn-xs") unless product_update.archived?
  end

  def product_update_delete_button(product_update)
    link_to("Delete", admin_profitbooks_workstream_path(product_update), :class => "btn btn-danger btn-xs", :method => 'delete', :remote => true) if product_update.archived?
  end

  def publish_button(product_update)
    link_to("Publish", publish_admin_profitbooks_workstream_path(product_update), :class => "btn btn-info btn-xs", :method=>'put', :remote => true) unless product_update.published? || product_update.archived?
  end

  def archive_button(product_update)
    link_to("Archive", archive_admin_profitbooks_workstream_path(product_update), :class => "btn btn-danger btn-xs", :method=>'put', :remote => true) if product_update.published?
  end

end
