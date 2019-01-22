class CreateInstamojoPayments < ActiveRecord::Migration
  def change
    create_table :instamojo_payments do |t|
      t.integer :company_id, :null => false
      t.string   :account_name, :null => false
      t.string :api_key, :null=> false
      t.string   :auth_key, :null => false
      t.string :status, :null => false

      t.timestamps
    end
  end
end
