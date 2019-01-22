class AddOpenedToDebitNotes < ActiveRecord::Migration
  def change
    add_column :debit_notes, :opened, :boolean, :default=>true
  end
end
