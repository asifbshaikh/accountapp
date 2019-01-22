class ProductSettingsController < ApplicationController
  # GET /product_settings
  # GET /product_settings.json
  respond_to :html, :json
  before_filter :page_menu
  def index
    @product_settings = ProductSetting.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @product_settings }
    end
  end

  # GET /product_settings/1
  # GET /product_settings/1.json
  def show
    @product_setting = ProductSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @product_setting }
    end
  end

  # GET /product_settings/new
  # GET /product_settings/new.json
  def new
    @product_setting = ProductSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @product_setting }
    end
  end

  # GET /product_settings/1/edit
  def edit
    @product_setting = ProductSetting.find(params[:id])
  end

  # POST /product_settings
  # POST /product_settings.json
  def create
    @product_setting = ProductSetting.new(params[:product_setting])

    respond_to do |format|
      if @product_setting.save
        format.html { redirect_to @product_setting, :notice => 'Product setting was successfully created.' }
        format.json { render :json => @product_setting, :status => :created, :location => @product_setting }
      else
        format.html { render :action => "new" }
        format.json { render :json => @product_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /product_settings/1
  # PUT /product_settings/1.json
  def update
    @product_setting = ProductSetting.find(params[:id])

    respond_to do |format|
      if @product_setting.update_attributes(params[:product_setting])
        if @product_setting.multilevel_pricing? && @company.product_pricing_levels.blank?
          ProductPricingLevel.create_pricing_levels(@company)
        end
        format.html { redirect_to @product_setting, :notice => 'Product setting was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @product_setting.errors, :status => :unprocessable_entity }
      end
    end
  end
  def update_level_caption
    product_pricing_level = ProductPricingLevel.find(params[:id])
    product_pricing_level.update_attributes(params[:product_pricing_level])
    redirect_to @company.product_setting
  end
  # DELETE /product_settings/1
  # DELETE /product_settings/1.json
  def destroy
    @product_setting = ProductSetting.find(params[:id])
    @product_setting.destroy

    respond_to do |format|
      format.html { redirect_to product_settings_url }
      format.json { head :ok }
    end
  end
  private
  def page_menu
    @menu = "Setting"
    @page_name = "Product setting"
  end
end
