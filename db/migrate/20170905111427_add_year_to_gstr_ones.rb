class AddYearToGstrOnes < ActiveRecord::Migration
  def change
    add_column :gstr_ones, :year, :string, :limit => 4
  end
end
