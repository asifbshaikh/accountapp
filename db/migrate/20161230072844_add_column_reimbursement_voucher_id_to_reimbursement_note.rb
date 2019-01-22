class AddColumnReimbursementVoucherIdToReimbursementNote < ActiveRecord::Migration
  def change
    add_column :reimbursement_notes, :reimbursement_voucher_id, :integer
  end
end
