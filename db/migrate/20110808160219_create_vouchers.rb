class CreateVouchers < ActiveRecord::Migration
  def self.up
    create_table :vouchers do |t|
      t.string :voucher_number
      t.string :type
      t.date :record_date
      t.date :due_date
      t.text :bill_reference
      t.date :bill_date
      t.integer :created_by
      t.integer :approved_by

      t.timestamps
    end
  end

  def self.down
    drop_table :vouchers
  end
end
