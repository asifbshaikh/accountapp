class CreateInvoiceStatuses < ActiveRecord::Migration
  def self.up
    create_table :invoice_statuses do |t|
      t.string :status, :null => false
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_statuses
  end
end
