class CreatePayheads < ActiveRecord::Migration
  def self.up
    create_table :payheads do |t|
      t.integer :company_id, :null => false
      t.integer :defined_by, :null => false
      t.string :payhead_type
      t.string :payhead_name
      t.string :under
      t.string :affect_net_salary
      t.string :name_appear_in_payslip
      t.string :use_of_gratuity
     

      t.timestamps
    end
  end

  def self.down
    drop_table :payheads
  end
end
