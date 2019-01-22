class CreateJournalImportLineItems < ActiveRecord::Migration
  def change
    create_table :journal_import_line_items do |t|
      t.integer :journal_import_id
      t.integer :from_account_id
      t.decimal :amount, :precision => 18, :scale => 2
      t.decimal :credit_amount, :precision => 18, :scale => 2

      t.timestamps
    end
  end
end
