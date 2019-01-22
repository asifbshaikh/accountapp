class PlanPropertiesController < ApplicationController
  # GET /plan_properties
  # GET /plan_properties.xml
  def index
    @plan_properties = PlanProperty.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @plan_properties }
    end
  end

  # GET /plan_properties/1
  # GET /plan_properties/1.xml
  def show
    @plan_property = PlanProperty.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @plan_property }
    end
  end

  # GET /plan_properties/new
  # GET /plan_properties/new.xml
  def new
    @plan_property = PlanProperty.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @plan_property }
    end
  end

  # GET /plan_properties/1/edit
  def edit
    @plan_property = PlanProperty.find(params[:id])
  end

  # POST /plan_properties
  # POST /plan_properties.xml
  def create
    @plan_property = PlanProperty.new(params[:plan_property])

    respond_to do |format|
      if @plan_property.save
        format.html { redirect_to(@plan_property, :notice => 'Plan property was successfully created.') }
        format.xml  { render :xml => @plan_property, :status => :created, :location => @plan_property }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @plan_property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /plan_properties/1
  # PUT /plan_properties/1.xml
  def update
    @plan_property = PlanProperty.find(params[:id])

    respond_to do |format|
      if @plan_property.update_attributes(params[:plan_property])
        format.html { redirect_to(@plan_property, :notice => 'Plan property was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @plan_property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /plan_properties/1
  # DELETE /plan_properties/1.xml
  def destroy
    @plan_property = PlanProperty.find(params[:id])
    @plan_property.destroy

    respond_to do |format|
      format.html { redirect_to(plan_properties_url) }
      format.xml  { head :ok }
    end
  end

  def access_permition
       
  end
end
