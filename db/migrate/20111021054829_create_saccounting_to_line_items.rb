class CreateSaccountingToLineItems < ActiveRecord::Migration
  def self.up
    create_table :saccounting_to_line_items do |t|
      t.integer :saccounting_id, :null => false
      t.integer :to_account_id, :null => false
        t.decimal :amount,:precision => 10, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :saccounting_to_line_items
  end
end