class FinancialYear < ActiveRecord::Migration

  def self.up
    create_table :financial_years do |t|
      t.integer :company_id, :null => false
      t.integer :year_id, :null => false
      t.boolean :freeze, :default => false 
    end
  end

  def self.down
    drop_table :financial_years
  end
end
