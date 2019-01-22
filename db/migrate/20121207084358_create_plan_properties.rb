class CreatePlanProperties < ActiveRecord::Migration
  def self.up
    create_table :plan_properties do |t|
      t.integer :plan_id
      t.string :name, :limit => 50
      t.string :value, :limit => 50
      t.string :datatype, :limit => 50

      t.timestamps
    end
  end

  def self.down
    drop_table :plan_properties
  end
end
