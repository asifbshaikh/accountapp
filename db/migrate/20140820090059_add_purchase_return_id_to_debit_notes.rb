class AddPurchaseReturnIdToDebitNotes < ActiveRecord::Migration
  def change
    add_column :debit_notes, :purchase_return_id, :integer
  end
end
