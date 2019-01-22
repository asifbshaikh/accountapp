class CreateGstr2as < ActiveRecord::Migration
  def change
    create_table :gstr2as do |t|
    	t.integer :id
    	t.integer :company_id, :null => false
    	t.integer :month
    	t.integer :year
    	t.integer :status, :default => 0
    	t.integer :financial_year_id, :null => false
    	t.integer :gst_return_id, :null => false
        t.string :error_message
    	t.date :start_date
    	t.date :end_date
    	t.string :token
      t.timestamps
    end
  end
end
