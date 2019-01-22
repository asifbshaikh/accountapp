class BlogController < ApplicationController
    layout :false
  skip_before_filter  :authorize_action, :authenticate, :check_if_allow, :check_messages, :company_active? 
  def index
    if params[:blog_category_id]
      @blog_posts = BlogPost.published_posts.where(:blog_category_id => params[:blog_category_id]).page(params[:page]).per(4)
    else
      @blog_posts = BlogPost.published_posts.page(params[:page]).per(4)
    end
    @categories = BlogCategory.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blog_posts }
    end
  end


  def show
    @blog_post = BlogPost.find_by_slug!(params[:id])
    @categories = BlogCategory.all    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog_post }
    end
  end

end
