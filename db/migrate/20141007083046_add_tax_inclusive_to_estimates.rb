class AddTaxInclusiveToEstimates < ActiveRecord::Migration
  def change
    add_column :estimates, :tax_inclusive, :boolean, :default=>false
  end
end
