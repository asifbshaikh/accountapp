class CreateVoucherSettings < ActiveRecord::Migration
  def change
    create_table :voucher_settings do |t|
      t.integer :company_id
      t.integer :voucher_number_strategy
      t.string :prefix
      t.string :suffix
      t.integer :voucher_type
      
      t.timestamps
    end
  end
end
