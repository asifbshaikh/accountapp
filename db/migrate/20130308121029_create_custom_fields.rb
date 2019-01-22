class CreateCustomFields < ActiveRecord::Migration
  def self.up
    create_table :custom_fields do |t|
      t.integer :company_id, :null => false
      t.string :voucher_type, :null => false
      t.string :custom_label1
      t.string :custom_label2
      t.string :custom_label3

      t.timestamps
    end
  end

  def self.down
    drop_table :custom_fields
  end
end
