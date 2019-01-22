class AddCustomerNotesAndTermsAndConditionsInVoucherSettings < ActiveRecord::Migration
  def up
     add_column :voucher_settings, :customer_notes, :text
     add_column :voucher_settings, :terms_and_conditions, :text
  end

  def down
    remove_column :voucher_settings, :customer_notes
    remove_column :voucher_settings, :terms_and_conditions
  end
end
