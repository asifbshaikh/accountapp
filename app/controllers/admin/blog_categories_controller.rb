class Admin::BlogCategoriesController < ApplicationController

  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user, :menu_title
skip_after_filter :intercom_rails_auto_include
  # GET /blog_categories
  # GET /blog_categories.xml
  def index
    @blog_categories = BlogCategory.all
    @blog_category = BlogCategory.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blog_categories }
    end
  end

  # GET /blog_categories/1
  # GET /blog_categories/1.xml
  def show
    @menu ="Blog"
    @page_name ="Blog categories"
    @blog_category = BlogCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog_category }
    end
  end

  # GET /blog_categories/new
  # GET /blog_categories/new.xml
  def new
    @blog_category = BlogCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blog_category }
    end
  end

  # GET /blog_categories/1/edit
  def edit
    @menu ="Blog"
    @page_name ="Blog categories"

    @blog_category = BlogCategory.find(params[:id])
  end

  # POST /blog_categories
  # POST /blog_categories.xml
  def create
    @blog_category = BlogCategory.new(params[:blog_category])

    respond_to do |format|
      if @blog_category.save
        format.html { redirect_to(admin_blog_categories_path, :notice => 'Blog category was successfully created.') }
        format.xml  { render :xml => @blog_categories, :status => :created, :location => @blog_category }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @blog_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blog_categories/1
  # PUT /blog_categories/1.xml
  def update
    @blog_category = BlogCategory.find(params[:id])

    respond_to do |format|
      if @blog_category.update_attributes(params[:blog_category])
        format.html { redirect_to([:admin, @blog_category], :notice => 'Blog category was successfully updated.') }
        # format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @blog_category.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@blog_category) }
      end
    end
  end

  # DELETE /blog_categories/1
  # DELETE /blog_categories/1.xml
  def destroy
    @blog_category = BlogCategory.find(params[:id])
    @post = BlogPost.find_by_blog_category_id(@blog_category.id)
    if @post.blank?
    @blog_category.destroy
    else
      flash[:error]="Some post created under the category you want to delete."
    end
    respond_to do |format|
      format.html { redirect_to(admin_blog_categories_path) }
      format.xml  { head :ok }
    end
  end

  def menu_title
    @menu = "Admin"
    @page_name = "Blog Categories"
  end
end
