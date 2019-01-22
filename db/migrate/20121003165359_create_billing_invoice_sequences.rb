class CreateBillingInvoiceSequences < ActiveRecord::Migration
  def self.up
    create_table :billing_invoice_sequences do |t|

    end
  end

  def self.down
    drop_table :billing_invoice_sequences
  end
end
