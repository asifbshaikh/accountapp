class AddReplyIdToSupports < ActiveRecord::Migration
  def self.up
    add_column :supports, :reply_id, :integer
  end

  def self.down
    remove_column :supports, :reply_id
  end
end
