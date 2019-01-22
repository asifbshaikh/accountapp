class CompaniesController < ApplicationController
  # GET /companies
  # GET /companies.xml
  def index
    @companies = Company.all.page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @companies }
    end
  end

  # GET /companies/1
  # GET /companies/1.xml
  def show
    @company = Company.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company }
    end
  end

  # GET /companies/new
  # GET /companies/new.xml
  def new
    @company = Company.new
    @company.build_address
    @company.old_file_size = 0
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = Company.find(params[:id])
    @company.old_file_size = @company.logo_file_size
    @countries = Country.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
  end

  # POST /companies
  # POST /companies.xml
  def create
    @company = Company.new(params[:company])
    @company.old_file_size = 0
    respond_to do |format|
      if @company.save
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " new company #{@company.name} with subdomain #{@company.subdomain}", "created", @current_user.branch_id)
        format.html { redirect_to(settings_show_url, :notice => 'Company was successfully created.') }
        format.xml  { render :xml => @company, :status => :created, :location => @company }
      else
        @menu = 'Company'
        @page_name = 'Create new company'
        format.html { render :action => "new" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /companies/1
  # PUT /companies/1.xml
  def update
    @company = Company.find(params[:id])
     @company.old_file_size = params[:old_file_size]
    respond_to do |format|
      if @company.update_attributes(params[:company])
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " company #{@company.name} with subdomain #{@company.subdomain}", "updated", @current_user.branch_id)
        format.js {render "/settings/edit"}
        format.html { redirect_to(settings_show_url, :notice => 'Company was successfully updated.') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        @countries = Country.all
        @currencies = Currency.all
        if @company.address.blank?
          @company.build_address
        end
        format.js {render "/settings/edit"}
        format.html { redirect_to(settings_show_url) }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@company) }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.xml
  def destroy
    @company = Company.find(params[:id])
    @company.status = 1
    @company.destroy
    Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    " company #{@company.name} with subdomain #{@company.subdomain} is marked as deleted", "deleted", @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to(companies_url) }
      format.xml  { head :ok }
    end
  end
def edit_logo
    data_logo = nil
    @company = Company.find(params[:id])
  end
  def update_logo
    @is_save = false
    @company = Company.find(params[:id])
    if @company.update_attribute(params[:user])
    @is_save = true
    else
    @is_save= false
   end
  end
#for logo download
 # def get
  #  @company = Company.find_by_id(params[:id])
  #  if @company
  #    send_file @company.logo.path, :type => @company.logo_content_type
  #  else
  #    flash[:error] = "Don't be cheeky! Mind your own assets!"
  #    redirect_to settings_show_url
  #  end
  #end
end
