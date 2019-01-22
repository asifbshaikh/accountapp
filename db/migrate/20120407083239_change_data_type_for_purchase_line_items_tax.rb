class ChangeDataTypeForPurchaseLineItemsTax < ActiveRecord::Migration
  def self.up
     change_table :purchase_line_items do |t|
      t.change :tax, :boolean
    end
  end

  def self.down
   change_table :purchase_line_items do |t|
      t.change :tax, :string
    end
  end
end
