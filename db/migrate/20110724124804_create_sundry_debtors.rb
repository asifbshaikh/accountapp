class CreateSundryDebtors < ActiveRecord::Migration
  def self.up
    create_table :sundry_debtors do |t|
      t.string :contact_number
      t.string :email
      t.string :PAN, :limit => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :sundry_debtors
  end
end
