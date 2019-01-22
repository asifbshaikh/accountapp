class CreateBankStatementLineItems < ActiveRecord::Migration
  def change
    create_table :bank_statement_line_items do |t|
      t.date :date
      t.string :from_account
      t.string :to_account
      t.decimal :amount
      t.text :description
      t.integer :status
      t.integer :bank_statement_id

      t.timestamps
    end
  end
end
