class CreateGstCategories < ActiveRecord::Migration
  def change
    create_table :gst_categories do |t|
      t.string :name, :null => false
      t.text :description
    end
  end
end
