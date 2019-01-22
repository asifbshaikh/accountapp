class CreateGstReturnTypes < ActiveRecord::Migration
  def change
    create_table :gst_return_types do |t|
      t.integer :gst_category_id, :null => false
      t.string :return_type, :null => false
      t.string :filing_frequency, :null => false, :limit => 100
      t.text :description
    end
  end
end
