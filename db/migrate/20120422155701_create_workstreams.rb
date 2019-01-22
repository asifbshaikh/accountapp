class CreateWorkstreams < ActiveRecord::Migration
  def self.up
    create_table :workstreams do |t|
      t.integer :company_id
      t.integer :user_id
      t.datetime :action_time
      t.string :IP_address, :limit => 100 
      t.string :action

      t.timestamps
    end
  end

  def self.down
    drop_table :workstreams
  end
end
