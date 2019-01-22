class CreateBlogPosts < ActiveRecord::Migration
  def self.up
    create_table :blog_posts do |t|
      t.string :title
      t.text :content
      t.integer :super_user_id
      t.integer :status
      t.integer :view_count

      t.timestamps
    end
  end

  def self.down
    drop_table :blog_posts
  end
end
