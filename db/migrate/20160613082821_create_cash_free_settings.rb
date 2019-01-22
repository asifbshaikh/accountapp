class CreateCashFreeSettings < ActiveRecord::Migration
  def change
    create_table :cash_free_settings do |t|
      t.integer :company_id, :null => false
      t.integer :account_id, :null => false
      t.string :app_id, :null=> false
      t.string   :secret_key, :null => false
      t.string :status, :null => false

      t.timestamps
    end
  end
end
