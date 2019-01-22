class AddIfscCodeToUserSalaryDetails < ActiveRecord::Migration
  def change
    add_column :user_salary_details, :ifsc_code, :string
  end
end
