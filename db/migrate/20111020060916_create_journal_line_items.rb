class CreateJournalLineItems < ActiveRecord::Migration
  def self.up
    create_table :journal_line_items do |t|
      t.integer :journal_id, :null => false
      t.integer :from_account_id, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :journal_line_items
  end
end
