class AddTaskIdToInvoiceLineItems < ActiveRecord::Migration
  def self.up
    add_column :invoice_line_items, :task_id, :integer
  end

  def self.down
    remove_column :invoice_line_items, :task_id
  end
end
