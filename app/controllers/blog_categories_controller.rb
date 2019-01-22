class BlogCategoriesController < ApplicationController
  # GET /blog_categories
  # GET /blog_categories.xml
  def index
    @blog_categories = BlogCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blog_categories }
    end
  end

  # GET /blog_categories/1
  # GET /blog_categories/1.xml
  def show
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
    @blog_category = BlogCategory.find(params[:id])
  end

  # POST /blog_categories
  # POST /blog_categories.xml
  def create
    @blog_category = BlogCategory.new(params[:blog_category])

    respond_to do |format|
      if @blog_category.save
        format.html { redirect_to([:admin, @blog_category], :notice => 'Blog category was successfully created.') }
        format.xml  { render :xml => @blog_category, :status => :created, :location => @blog_category }
      else
        format.html { render :action => "new" }
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
        format.html { redirect_to( [:admin, @blog_category], :notice => 'Blog category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blog_categories/1
  # DELETE /blog_categories/1.xml
  def destroy
    @blog_category = BlogCategory.find(params[:id])
    @blog_category.destroy

    respond_to do |format|
      format.html { redirect_to(blog_categories_url) }
      format.xml  { head :ok }
    end
  end
end
