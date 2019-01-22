class CreateCurrentLiabilities < ActiveRecord::Migration
  def self.up
    create_table :current_liabilities do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :current_liabilities
  end
end
