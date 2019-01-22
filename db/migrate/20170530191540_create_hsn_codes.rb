class CreateHsnCodes < ActiveRecord::Migration
  def change
    create_table :hsn_codes do |t|
    	t.string :product_code
    	t.string :HSN_Code 
    	t.text :description

      t.timestamps
    end
  end
end
