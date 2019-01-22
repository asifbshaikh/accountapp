class AddAccountIdToInstamojoPayments < ActiveRecord::Migration
  def change 
  	add_column :instamojo_payments,:account_id,:integer,:null => false
  end
end
