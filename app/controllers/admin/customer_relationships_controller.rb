class Admin::CustomerRelationshipsController < ApplicationController
  # GET /customer_relationships
  # GET /customer_relationships.xml
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user
skip_after_filter :intercom_rails_auto_include
  def index
    @customer_relationships = CustomerRelationship.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customer_relationships }
    end
  end

  # GET /customer_relationships/1
  # GET /customer_relationships/1.xml
  def show
    @customer_relationship = CustomerRelationship.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer_relationship }
    end
  end

  # GET /customer_relationships/new
  # GET /customer_relationships/new.xml
  def new
    @customer_relationship = CustomerRelationship.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer_relationship }
    end
  end

  # GET /customer_relationships/1/edit
  def edit
    @customer_relationship = CustomerRelationship.find(params[:id])
  end

  # POST /customer_relationships
  # POST /customer_relationships.xml
  def create
    @customer_relationship = CustomerRelationship.new(params[:customer_relationship])
    @customer_relationship.last_contact_date = Time.zone.now.to_date
    respond_to do |format|
      if @customer_relationship.save
        format.html { redirect_to("/admin/companies/#{@customer_relationship.company_id}", :notice => 'Customer relationship was successfully created.') }
        format.xml  { render :xml => @customer_relationship, :status => :created, :location => @customer_relationship }
      else
        format.html { redirect_to("/admin/companies/#{@customer_relationship.company_id}") }
        flash[:error] = "Notes can not be blank"
        format.xml  { render :xml => @customer_relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /customer_relationships/1
  # PUT /customer_relationships/1.xml
  def update
    @customer_relationship = CustomerRelationship.find(params[:id])

    respond_to do |format|
      if @customer_relationship.update_attributes(params[:customer_relationship])
        format.html { redirect_to(@customer_relationship, :notice => 'Customer relationship was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer_relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_relationships/1
  # DELETE /customer_relationships/1.xml
  def destroy
    @customer_relationship = CustomerRelationship.find(params[:id])
    @customer_relationship.destroy

    respond_to do |format|
      format.html { redirect_to(customer_relationships_url) }
      format.xml  { head :ok }
    end
  end




end
