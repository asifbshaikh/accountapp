class CreateInvoiceReturnSequences < ActiveRecord::Migration
  def change
    create_table :invoice_return_sequences do |t|
      t.integer :company_id
      t.integer :invoice_return_sequence

      t.timestamps
    end
  end
end
