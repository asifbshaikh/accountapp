class CreateGstrTwos < ActiveRecord::Migration
  def change
    create_table :gstr_twos do |t|
    	t.integer :company_id,:null => false
 		t.integer :financial_year_id,:null => false
 		t.integer :month
 		t.integer :status
 		t.string :year, :limit=>4
 		t.string :error_msg
      t.timestamps
    end
  end
end
