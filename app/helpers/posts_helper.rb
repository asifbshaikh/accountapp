module PostsHelper
 def join_tags(post)
    post.post_tags.map { |t| t.name }.join(", ")
  end
end
