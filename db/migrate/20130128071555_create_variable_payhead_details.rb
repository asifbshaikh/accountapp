class CreateVariablePayheadDetails < ActiveRecord::Migration
  def self.up
    create_table :variable_payhead_details do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :payhead_id, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0, :null => false
      t.date :month

      t.timestamps
    end
  end

  def self.down
    drop_table :variable_payhead_details
  end
end
