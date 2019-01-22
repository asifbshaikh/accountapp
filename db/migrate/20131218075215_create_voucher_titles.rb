class CreateVoucherTitles < ActiveRecord::Migration
  def change
    create_table :voucher_titles do |t|
      t.integer :company_id, :null => false
      t.string :voucher_type, :null => false
      t.string :voucher_title
      t.boolean :status, :default => true
      t.timestamps
    end
  end
end
