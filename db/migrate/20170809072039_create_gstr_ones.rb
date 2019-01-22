class CreateGstrOnes < ActiveRecord::Migration
  def change
    create_table :gstr_ones do |t|

    	t.integer :company_id,:null => false
  		t.integer :financial_year_id,:null => false
  		t.date :due_date, :null => false
  		t.integer :month
  		t.integer :status

      t.timestamps
    end
  end
end
