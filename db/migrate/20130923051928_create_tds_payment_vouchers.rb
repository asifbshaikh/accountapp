class CreateTdsPaymentVouchers < ActiveRecord::Migration
  def change
    create_table :tds_payment_vouchers do |t|
      t.integer :company_id, :null=> false
      t.integer :created_by, :null => false
      t.integer :branch_id
      t.date :payment_date
      t.string :tan_no, :null => false
      t.integer :assessment_year, :null=> false
      t.integer :tds_account_id, :null=> false
      t.integer :account_id, :null => false
      t.string :cin_no
      t.string :bsr_code
      t.string :challan_no
      t.decimal :basic_tax, :decimal, :precision => 18, :scale => 2, :default => 0 
      t.decimal :surcharge, :decimal, :precision => 18, :scale => 2, :default => 0 
      t.decimal :edu_cess, :decimal, :precision => 18, :scale => 2, :default => 0 
      t.decimal :other, :decimal, :precision => 18, :scale => 2, :default => 0 
      t.decimal :penalty, :decimal, :precision => 18, :scale => 2, :default => 0 
      t.decimal :interest, :decimal, :precision => 18, :scale => 2, :default => 0 
      t.text :description

      t.timestamps
    end
  end
end
