class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :estimate_label
      t.string :warehouse_label
      t.string :customer_label

      t.timestamps
    end
  end
end
