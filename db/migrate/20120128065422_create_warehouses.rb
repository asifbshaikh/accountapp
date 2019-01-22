class CreateWarehouses < ActiveRecord::Migration
  def self.up
    create_table :warehouses do |t|
      t.integer :company_id, :null => false
      t.integer :manager_id
      t.string :name
      t.string :address
      t.string :phone
      t.string :city
      t.string :pincode
      t.integer :created_by, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :warehouses
  end
end
