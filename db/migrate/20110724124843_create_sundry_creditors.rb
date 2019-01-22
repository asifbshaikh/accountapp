class CreateSundryCreditors < ActiveRecord::Migration
  def self.up
    create_table :sundry_creditors do |t|
      t.string :contact_number
      t.string :email
      t.string :PAN, :limit => 10
      t.string :sales_tax_number, :limit => 50
      t.timestamps
    end
  end

  def self.down
    drop_table :sundry_creditors
  end
end
