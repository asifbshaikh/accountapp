class CreateGstr2aLineItems < ActiveRecord::Migration
  def change
    create_table :gstr2a_line_items do |t|
    	t.integer :id
    	t.integer :company_id, :null => false
    	t.integer :gstr2a_item_id, :null => false
    	t.integer :item_id 
    	t.decimal :taxable_value, :precision => 11, :scale => 2
    	t.decimal :igst_amt, :precision => 11, :scale => 2
    	t.decimal :cgst_amt, :precision => 11, :scale => 2
    	t.decimal :sgst_amt, :precision => 11, :scale => 2
    	t.decimal :cess_amt, :precision => 11, :scale => 2
    	t.decimal :tax_rate, :precision => 3, :scale => 2
      t.timestamps
    end
  end
end
