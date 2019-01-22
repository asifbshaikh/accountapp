class CreateGstrTwoItems < ActiveRecord::Migration
  def change
    create_table :gstr_two_items do |t|
    	t.integer :company_id,:null => false
  		t.integer :gstr_two_id,:null => false
  		t.integer :voucher_id,:null => false
  		t.string :voucher_type
      t.string :voucher_number
  		t.integer :voucher_classification
  		t.integer :status
      	t.string :error_msg

      t.timestamps
    end
  end
end
