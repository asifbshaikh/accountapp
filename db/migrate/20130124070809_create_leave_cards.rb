class CreateLeaveCards < ActiveRecord::Migration
  def self.up
    create_table :leave_cards do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :leave_type_id, :null => false
      t.integer :card_year, :limit => 2, :null => false
      t.integer :total_leave_cnt, :limit => 2, :null => false, :default =>0
      t.decimal :utilized_leave_cnt, :precision =>4, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :leave_cards
  end
end
