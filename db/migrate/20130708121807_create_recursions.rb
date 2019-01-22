class CreateRecursions < ActiveRecord::Migration
  def self.up
    create_table :recursions do |t|
      t.integer :company_id
      t.integer :recursive_id
      t.string :recursive_type
      t.date :schedule_on
      t.integer :frequency
      t.integer :iteration
      t.integer :utilized_iteration
      t.boolean :status

      t.timestamps
    end
  end

  def self.down
    drop_table :recursions
  end
end
