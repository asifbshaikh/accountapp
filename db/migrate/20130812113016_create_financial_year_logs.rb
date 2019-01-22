class CreateFinancialYearLogs < ActiveRecord::Migration
  def change
    create_table :financial_year_logs do |t|
      t.integer :company_id
      t.integer :financial_year_id
      t.datetime :activity_on
      t.integer :activity
      t.decimal :past_opening_balance, :default => 0.00
      t.decimal :past_closing_balance, :default => 0.00
      t.integer :created_by

      t.timestamps
    end
  end
end
