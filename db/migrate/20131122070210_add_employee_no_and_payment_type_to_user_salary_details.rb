class AddEmployeeNoAndPaymentTypeToUserSalaryDetails < ActiveRecord::Migration
  def change
    add_column :user_salary_details, :employee_no, :string
    add_column :user_salary_details, :payment_type, :string
  end
end
