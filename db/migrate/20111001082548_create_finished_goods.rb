class CreateFinishedGoods < ActiveRecord::Migration
  def self.up
    create_table :finished_goods do |t|
      t.integer :company_id, :null => false
      t.integer :user_id
      t.integer :inventory_id, :null => false
      t.integer :recieved_from
      t.integer :quantity
      t.date :recieved_date

      t.timestamps
    end
  end

  def self.down
    drop_table :finished_goods
  end
end
