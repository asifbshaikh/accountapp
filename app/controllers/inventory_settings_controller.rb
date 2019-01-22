class InventorySettingsController < ApplicationController

  before_filter :menu_title

  # GET /inventory_settings
  # GET /inventory_settings.json
  def index
    @inventory_settings = InventorySetting.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @inventory_settings }
    end
  end

  # GET /inventory_settings/1
  # GET /inventory_settings/1.json
  def show

    @inventory_setting = InventorySetting.find_by_company(@company)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @inventory_setting }
    end
  end

  # GET /inventory_settings/new
  # GET /inventory_settings/new.json
  def new
    @inventory_setting = InventorySetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @inventory_setting }
    end
  end

  # GET /inventory_settings/1/edit
  def edit
    @inventory_setting = InventorySetting.find(params[:id])
  end

  # POST /inventory_settings
  # POST /inventory_settings.json
  def create
    @inventory_setting = InventorySetting.new(params[:inventory_setting])

    respond_to do |format|
      if @inventory_setting.save
        format.html { redirect_to @inventory_setting, :notice => 'Inventory setting was successfully created.' }
        format.json { render :json => @inventory_setting, :status => :created, :location => @inventory_setting }
      else
        format.html { render :action => "new" }
        format.json { render :json => @inventory_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_settings/1
  # PUT /inventory_settings/1.json
  def update
    @inventory_setting = InventorySetting.find(params[:id])

    respond_to do |format|
      if @inventory_setting.update_attributes(params[:inventory_setting])
        format.html { redirect_to @inventory_setting, :notice => 'Inventory setting was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @inventory_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_settings/1
  # DELETE /inventory_settings/1.json
  def destroy
    @inventory_setting = InventorySetting.find(params[:id])
    @inventory_setting.destroy

    respond_to do |format|
      format.html { redirect_to inventory_settings_url }
      format.json { head :ok }
    end
  end

  private

    def menu_title
      @menu = 'Inventory Settings'
      @page_name = 'Details'
    end

end
