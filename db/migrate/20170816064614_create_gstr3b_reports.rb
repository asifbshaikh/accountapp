class CreateGstr3bReports < ActiveRecord::Migration
  def change
    create_table :gstr3b_reports do |t|
      t.integer :company_id, :null => false
      t.integer :financial_year_id, :null => false
      t.integer :month, :null => false
      t.string  :gstin, :limit => 15, :null => false
      t.integer :status, :null => false
      t.string  :name, :null=> false
      t.integer :verified_by        
      t.timestamps
    end
  end
end
