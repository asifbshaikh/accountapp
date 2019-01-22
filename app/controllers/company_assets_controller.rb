class CompanyAssetsController < ApplicationController
  # layout "payroll"#, :except => [:show]
  # GET /companyassets
  # GET /companyassets.xml
  # layout :chose_layout
  def index
    @users = @company.users
    # @search = @company.company_assets.search(params[:search])
    @company_assets = @company.company_assets.page(params[:page]).per(20)
    @company_asset = CompanyAsset.new(params[:company_asset])
    respond_to do |format|
      format.html # index.html.erb
      # format.html # new.html.erb
      format.xml  { render :xml => @company_assets }
    end
  end

  def my_asset
    @menu = 'Self Service'
    @page_name = 'My Asset'
    @search = CompanyAsset.where(:assigned_to => @current_user.id).search(params[:search])
    @company_assets = @search.page(params[:page]).per(20)
  end

  # GET /companyassets/1
  # GET /companyassets/1.xml
  def show
    @menu = 'Administration'
    @page_name = 'View Asset'
    @company_asset = CompanyAsset.find(params[:id])
    @users = @company.users
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company_asset }
    end
  end

  def new
    @menu = 'Self Service'
    @page_name = 'Manage Assets'
    @users = @company.users
    @company_asset = CompanyAsset.new
    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @company_assets }
    end
  end

  # GET /companyassets/1/edit
  def edit
    @menu = 'Administration'
    @page_name = 'Manage Assets'
    @company_asset = CompanyAsset.find(params[:id])
    @users = @company.users
  end

  # POST /companyassets
  # POST /companyassets.xml
  def create
    @company_asset = CompanyAsset.new(params[:company_asset])
    @users = @company.users
    @company_asset.company_id = @company.id
    @company_asset.user_id = @current_user.id
    respond_to do |format|
      if @company_asset.save
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " new  asset #{@company_asset.asset_tag} purchased on #{@company_asset.purchase_date} in #{@company.name}", "created", @current_user.branch_id)
        flash[:success]= "Asset successfully created."
        format.html { redirect_to company_assets_path }
        format.xml  { render :xml => @company_asset, :status => :created, :location => @company_asset }
      else
        @menu = 'Administration'
        @page_name = 'Manage Assets'
        @users = @company.users
        @search = @company.company_assets.search(params[:search])
        @company_assets = @search.all
        format.html { render :action => "index" }
        format.xml  { render :xml => @company_asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /companyassets/1
  # PUT /companyassets/1.xml
  def update
    @company_asset = CompanyAsset.find(params[:id])
    @users = @company.users
    respond_to do |format|
      if @company_asset.update_attributes(params[:company_asset])
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " asset #{@company_asset.asset_tag} purchased on #{@company_asset.purchase_date} in #{@company.name}", "updated", @current_user.branch_id)
        format.html { redirect_to(@company_asset, :notice => 'Asset was successfully updated.') }
        # format.xml  { head :ok }
        format.json { head :ok }
      else
        # @menu = 'Administration'
        # @page_name = 'Manage Assets'
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @company_asset.errors, :status => :unprocessable_entity }
         format.json { respond_with_bip(@company_asset) }
      end
    end
  end

  # DELETE /companyassets/1
  # DELETE /companyassets/1.xml
  def destroy
    @company_asset = CompanyAsset.find(params[:id])
    @company_asset.destroy
    Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    " #{@company_asset.asset_tag} purchased on #{@company_asset.purchase_date} in #{@company.name} is marked for deletion", "deleted", @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to(company_assets_url, :notice => 'Asset has been successfully deleted.') }
      format.xml  { head :ok }
    end
  end
  
  private

  def chose_layout
    session[:current_app_id] == 1 ? 'application' : 'payroll'
  end

end
