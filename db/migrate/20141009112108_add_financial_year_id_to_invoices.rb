class AddFinancialYearIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :financial_year_id, :integer
  end
end
