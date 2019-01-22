class AddReadOnlyToDebitNotes < ActiveRecord::Migration
  def change
    add_column :debit_notes, :read_only, :boolean, :default=>false
  end
end
