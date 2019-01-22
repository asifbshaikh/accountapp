class CreateGstr2aItems < ActiveRecord::Migration
  def change
    create_table :gstr2a_items do |t|
    	t.integer :id
    	t.integer :company_id, :null => false
    	t.integer :gstr2a_id, :null => false
    	t.integer :category
    	t.integer :ctin
    	t.string :chksum, :limit => 64
    	t.string :voucher_num, :limit => 16
    	t.string :voucher_type
    	t.date :voucher_date
    	t.decimal :voucher_value, :precision => 15, :scale => 2
    	t.string :place_of_supply, :limit => 2
    	t.boolean :reverse_charge, :null => false, :default => false
      t.timestamps
    end
  end
end
