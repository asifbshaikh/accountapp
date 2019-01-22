class AddQunatityRateToTemplateMargin < ActiveRecord::Migration
  def change
  	    add_column :template_margins, :HideRateQuantity, :integer , :default=>1
  end
end
