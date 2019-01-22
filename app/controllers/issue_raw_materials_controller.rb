class IssueRawMaterialsController < ApplicationController

  layout "application", :except => [:show]
  # GET /issue_raw_materials
  # GET /issue_raw_materials.xml
  def index
    @issue_raw_materials = IssueRawMaterial.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @issue_raw_materials }
    end
  end

  # GET /issue_raw_materials/1
  # GET /issue_raw_materials/1.xml
  def show
    @issue_raw_material = IssueRawMaterial.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue_raw_material }
    end
  end

  # GET /issue_raw_materials/new
  # GET /issue_raw_materials/new.xml
  def new
    @issue_raw_material = IssueRawMaterial.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @issue_raw_material }
    end
  end

  # GET /issue_raw_materials/1/edit
  def edit
    @issue_raw_material = IssueRawMaterial.find(params[:id])
  end

  # POST /issue_raw_materials
  # POST /issue_raw_materials.xml
  def create
    @issue_raw_material = IssueRawMaterial.new(params[:issue_raw_material])

    respond_to do |format|
      if @issue_raw_material.save
        format.html { redirect_to(@issue_raw_material, :notice => 'Issue raw material was successfully created.') }
        format.xml  { render :xml => @issue_raw_material, :status => :created, :location => @issue_raw_material }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @issue_raw_material.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /issue_raw_materials/1
  # PUT /issue_raw_materials/1.xml
  def update
    @issue_raw_material = IssueRawMaterial.find(params[:id])

    respond_to do |format|
      if @issue_raw_material.update_attributes(params[:issue_raw_material])
        format.html { redirect_to(@issue_raw_material, :notice => 'Issue raw material was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @issue_raw_material.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /issue_raw_materials/1
  # DELETE /issue_raw_materials/1.xml
  def destroy
    @issue_raw_material = IssueRawMaterial.find(params[:id])
    @issue_raw_material.destroy

    respond_to do |format|
      format.html { redirect_to(issue_raw_materials_url) }
      format.xml  { head :ok }
    end
  end
end
