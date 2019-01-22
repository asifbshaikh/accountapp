class ChangeProductIdToNotNullInGstrAdvancePayment < ActiveRecord::Migration
  def up
  	change_column :gstr_advance_payment_line_items, :product_id, :integer, :null => true
  end

  def down
  end
end
