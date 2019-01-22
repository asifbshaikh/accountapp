class AddOpeningStockValuationAndClosingStockValuationToFinancialYears < ActiveRecord::Migration
  def change
    add_column :financial_years, :opening_stock_valuation, :decimal, :precision=>18, :scale=>2, :default=>0
    add_column :financial_years, :closing_stock_valuation, :decimal, :precision=>18, :scale=>2, :default=>0
  end
end
