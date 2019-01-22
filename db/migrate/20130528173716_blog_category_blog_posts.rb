class BlogCategoryBlogPosts < ActiveRecord::Migration
  def self.up
    create_table :blog_category_blog_posts do |t|
      t.integer :blog_category_id, :null => false
      t.integer :blog_post_id, :null => false
    end

  end

  def self.down
    drop_table :blog_category_blog_posts
  end
end
