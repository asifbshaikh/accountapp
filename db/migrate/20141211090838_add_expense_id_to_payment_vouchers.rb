class AddExpenseIdToPaymentVouchers < ActiveRecord::Migration
  def change
    add_column :payment_vouchers, :expense_id, :integer
  end
end
