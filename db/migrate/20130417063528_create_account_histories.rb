class CreateAccountHistories < ActiveRecord::Migration
  def self.up
  create_table :account_histories do |t|
      t.integer :company_id, :null => false
      t.integer :account_id, :null => false
      t.integer :financial_year_id, :null => false
      t.decimal :opening_balance, :precision => 18, :scale => 2, :default =>0
      t.decimal :closing_balance, :precision => 18, :scale => 2
      
      t.timestamps
  end
 end
  def self.down
    drop_table :account_histories
  end
end
