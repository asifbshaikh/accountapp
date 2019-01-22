class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.integer :company_id, :null => false
      t.integer :submitted_by
      t.string :vote
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
