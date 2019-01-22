class CreatePbreferrals < ActiveRecord::Migration
  def change
    create_table :pbreferrals do |t|
      t.integer :company_id, :null => false
      t.integer :invited_by, :null => false
      t.integer :coupon_id, :null=> false
      t.string :name
      t.string :email, :null => false, :limit => 100
      t.integer :status, :default => 0
      t.string :token, :null => false
      t.decimal :earning, :precision => 18, :scale => 2, :default => 0
      t.integer :invitee_company_id
      t.timestamps
    end
  end
end
