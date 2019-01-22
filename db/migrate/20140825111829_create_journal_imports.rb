class CreateJournalImports < ActiveRecord::Migration
  def change
    create_table :journal_imports do |t|
      t.integer :import_file_id
      t.string :voucher_number
      t.date :date
      t.integer :created_by
      t.text :description
      t.string :tags
      t.decimal :total_amount, :precision => 18, :scale => 2
      t.integer :from_account_id
      t.decimal :amount, :precision => 18, :scale => 2
      t.decimal :credit_amount, :precision => 18, :scale => 2
      t.integer :status

      t.timestamps
    end
  end
end
