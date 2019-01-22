class VoucherSettingsController < ApplicationController
  # GET /voucher_settings
  # GET /voucher_settings.json
  def index
    @voucher_settings = VoucherSetting.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @voucher_settings }
    end
  end

  # GET /voucher_settings/1
  # GET /voucher_settings/1.json
  def show
    @voucher_setting = VoucherSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @voucher_setting }
    end
  end

  # GET /voucher_settings/new
  # GET /voucher_settings/new.json
  def new
    @voucher_setting = VoucherSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @voucher_setting }
    end
  end

  # GET /voucher_settings/1/edit
  def edit
    @voucher_setting = VoucherSetting.find(params[:id])
  end

  # POST /voucher_settings
  # POST /voucher_settings.json
  def create
    @voucher_setting = VoucherSetting.new(params[:voucher_setting])

    respond_to do |format|
      if @voucher_setting.save
        format.html { redirect_to @voucher_setting, :notice => 'Voucher setting was successfully created.' }
        format.json { render :json => @voucher_setting, :status => :created, :location => @voucher_setting }
      else
        format.html { render :action => "new" }
        format.json { render :json => @voucher_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /voucher_settings/1
  # PUT /voucher_settings/1.json
  def update
    @voucher_setting = VoucherSetting.find(params[:id])

    respond_to do |format|
      if @voucher_setting.update_attributes(params[:voucher_setting])
        format.html { redirect_to @voucher_setting, :notice => 'Voucher setting was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @voucher_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /voucher_settings/1
  # DELETE /voucher_settings/1.json
  def destroy
    @voucher_setting = VoucherSetting.find(params[:id])
    @voucher_setting.destroy

    respond_to do |format|
      format.html { redirect_to voucher_settings_url }
      format.json { head :ok }
    end
  end
end
