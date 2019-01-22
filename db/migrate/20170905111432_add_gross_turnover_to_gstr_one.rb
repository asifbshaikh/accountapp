class AddGrossTurnoverToGstrOne < ActiveRecord::Migration
  def change
    add_column :gstr_ones, :fy_gross_turnover, :decimal, :precision=> 18, :scale=>2, :default => 2
    add_column :gstr_ones, :qtr_gross_turnover, :decimal, :precision=> 18, :scale=>2, :default => 2
  end
end
