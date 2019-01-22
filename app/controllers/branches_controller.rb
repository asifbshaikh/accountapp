class BranchesController < ApplicationController
  # before_filter :menu_title
  # GET /branches
  # GET /branches.xml
  def index
    @search = @company.branches.search(params[:search])
    @branches = @search.page(params[:page]).per(20)
    @branch = Branch.new
    @branch.build_address
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @branches }
    end
  end

  # GET /branches/1
  # GET /branches/1.xml
  def show
    @branch = Branch.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @branch }
    end
  end

  # GET /branches/new
  # GET /branches/new.xml
  def new
    @branch = Branch.new
    @branch.build_address
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @branch }
    end
  end

  # GET /branches/1/edit
  def edit
    @branch = Branch.find(params[:id])
  end

  # POST /branches
  # POST /branches.xml
  def create
    @branch = Branch.new(params[:branch])
    @branch.created_by = @current_user.id
    @company.branches << @branch

    respond_to do |format|
      if @branch.save
        format.html { redirect_to("/settings/show#branch", :notice => 'Branch was successfully created.') }
        format.xml  { render :xml => @branch, :status => :created, :location => @branch }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @branch.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /branches/1
  # PUT /branches/1.xml
  def update
    @branch = Branch.find(params[:id])

    respond_to do |format|
      if @branch.update_attributes(params[:branch])
        format.html { redirect_to("/settings/show#branch", :notice => 'Branch was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @branch.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /branches/1
  # DELETE /branches/1.xml
  def destroy
    @branch = Branch.find(params[:id])
    @branch.destroy

    respond_to do |format|
      format.html { redirect_to(branches_url) }
      format.xml  { head :ok }
    end
  end

  def get_state
    @state=State.all
  end
  

end
