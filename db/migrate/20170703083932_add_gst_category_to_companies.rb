class AddGstCategoryToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :gst_category_id, :integer
  end
end
