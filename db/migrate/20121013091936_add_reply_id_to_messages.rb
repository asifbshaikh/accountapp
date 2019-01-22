class AddReplyIdToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :reply_id, :integer
  end

  def self.down
    remove_column :messages, :reply_id
  end
end
