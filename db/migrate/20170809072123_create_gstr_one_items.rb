class CreateGstrOneItems < ActiveRecord::Migration
  def change
    create_table :gstr_one_items do |t|
    	t.integer :company_id,:null => false
  		t.integer :gstr_one_id,:null => false
  		t.integer :company_id,:null => false
  		t.integer :voucher_id,:null => false
  		t.string :voucher_type
  		t.integer :voucher_classification
  		t.integer :status

      t.timestamps
    end
  end
end
