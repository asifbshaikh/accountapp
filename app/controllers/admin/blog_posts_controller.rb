class Admin::BlogPostsController < ApplicationController

  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user
  skip_after_filter :intercom_rails_auto_include

  # GET /blog_posts
  # GET /blog_posts.xml
  def index
    @blog_posts = BlogPost.where(:super_user_id => 1).order("created_at DESC").page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blog_posts }
    end
  end

  # GET /blog_posts/1
  # GET /blog_posts/1.xml
  def show
    @menu = 'Blog'
    @page_name = 'View Blog Post'
        @blog_post = BlogPost.find_by_slug!(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog_post }
    end
  end

  # GET /blog_posts/new
  # GET /blog_posts/new.xml
  def new
    @blog_post = BlogPost.new
    @categories = BlogCategory.all
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blog_post }
    end
  end

  # GET /blog_posts/1/edit
  def edit
    @blog_post = BlogPost.find_by_slug!(params[:id])
    @categories = BlogCategory.all
  end

  # POST /blog_posts
  # POST /blog_posts.xml
  def create
    @blog_post = BlogPost.new(params[:blog_post])
    # @blog_post.super_user_id = session[:current_super_user_id].to_i
    @blog_post.status = blog_status params
      
    respond_to do |format|
      if @blog_post.save
        format.html { redirect_to([:admin, @blog_post], :notice => 'Blog post was successfully created_at.')  }
        format.xml  { render :xml => @blog_post, :status => :created, :location => @blog_post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blog_posts/1
  # PUT /blog_posts/1.xml
  def update
   @blog_post = BlogPost.find_by_slug!(params[:id])
    @blog_post.status = blog_status params

    respond_to do |format|
      if @blog_post.update_attributes(params[:blog_post])
        format.html { redirect_to([:admin, @blog_post], :notice => 'Blog post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blog_posts/1
  # DELETE /blog_posts/1.xml
  def destroy
    @blog_post = BlogPost.find(params[:id])
    @blog_post.destroy

    respond_to do |format|
      format.html { redirect_to(blog_posts_url) }
      format.xml  { head :ok }
    end
  end

  private
  
    def blog_status(params)
      if params['draft']
        1
      else
        0
      end
    end
end
