class AddValidTillDateToSalaryStructures < ActiveRecord::Migration
  def change
    add_column :salary_structures, :valid_till_date, :date
  end
end
