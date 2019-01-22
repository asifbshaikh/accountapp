class AddCompanyIdToTemplateMargin < ActiveRecord::Migration
  def change
  	add_column :template_margins,:company_id,:integer,:null => false
  end
end
