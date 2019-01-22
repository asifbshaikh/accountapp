class CreatePayrollSettings < ActiveRecord::Migration
  def change
    create_table :payroll_settings do |t|
	  t.integer :company_id  	
      t.boolean :enable_payslip_signatory, :default => false
      t.string :payslip_footer
      t.timestamps
    end
  end
end
