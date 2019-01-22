class AddDescriptionAndAuthorToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :description, :string
    add_column :blog_posts,:author, :string
  end
end
