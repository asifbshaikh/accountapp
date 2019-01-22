class CreateCustomerRelationships < ActiveRecord::Migration
  def self.up
    create_table :customer_relationships do |t|
      t.integer :company_id
      t.text :notes
      t.date :last_contact_date
      t.date :next_contact_date
      t.integer :created_by

      t.timestamps
    end
  end

  def self.down
    drop_table :customer_relationships
  end
end
