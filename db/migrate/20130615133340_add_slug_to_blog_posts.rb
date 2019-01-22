class AddSlugToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :slug, :text
  end

  def self.down
    remove_column :blog_posts, :slug
  end
end
