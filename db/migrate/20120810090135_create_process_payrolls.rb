class CreateProcessPayrolls < ActiveRecord::Migration
  def self.up
    create_table :process_payrolls do |t|
      t.integer :user_id
      t.integer :company_id
      t.string :month
      t.integer :attendance

      t.timestamps
    end
  end

  def self.down
    drop_table :process_payrolls
  end
end
