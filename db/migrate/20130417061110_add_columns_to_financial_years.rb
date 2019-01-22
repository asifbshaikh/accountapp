class AddColumnsToFinancialYears < ActiveRecord::Migration
  def self.up
    add_column :financial_years, :opening_balance, :decimal, :precision => 18, :scale => 2, :default =>0
    add_column :financial_years, :closing_balance, :decimal, :precision => 18, :scale => 2
  end

  def self.down
    remove_column :financial_years, :closing_balance
    remove_column :financial_years, :opening_balance
  end
end
