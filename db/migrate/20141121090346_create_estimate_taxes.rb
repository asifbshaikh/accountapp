class CreateEstimateTaxes < ActiveRecord::Migration
  def change
    create_table :estimate_taxes do |t|
      t.integer :estimate_line_item_id, :null=>false
      t.integer :account_id, :null=>false

      t.timestamps
    end
  end
end
