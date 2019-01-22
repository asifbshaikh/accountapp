class AddCreditAmountToJournalLineItems < ActiveRecord::Migration
  def change
    add_column :journal_line_items, :credit_amount, :decimal, :precision => 18, :scale => 2, :default => 0
  end
end
