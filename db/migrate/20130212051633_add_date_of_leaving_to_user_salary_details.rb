class AddDateOfLeavingToUserSalaryDetails < ActiveRecord::Migration
  def self.up
    add_column :user_salary_details, :date_of_leaving, :date
  end

  def self.down
    remove_column :user_salary_details, :date_of_leaving
  end
end
