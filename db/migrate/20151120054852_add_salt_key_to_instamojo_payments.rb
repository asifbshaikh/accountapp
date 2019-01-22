class AddSaltKeyToInstamojoPayments < ActiveRecord::Migration
  def change
  	add_column :instamojo_payments, :salt_key, :text, :null => false
  end
end
