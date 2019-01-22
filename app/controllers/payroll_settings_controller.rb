class PayrollSettingsController < ApplicationController
  # skip_before_filter :authorize_action
  # GET /payroll_settings
  # GET /payroll_settings.json
  def index
    @payroll_settings = PayrollSetting.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payroll_settings }
    end
  end

  # GET /payroll_settings/1
  # GET /payroll_settings/1.json
  def show
    @payroll_setting = PayrollSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payroll_setting }
    end
  end

  # GET /payroll_settings/new
  # GET /payroll_settings/new.json
  def new
    @payroll_setting = PayrollSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payroll_setting }
    end
  end

  # GET /payroll_settings/1/edit
  def edit
    @payroll_setting = PayrollSetting.find(params[:id])
  end

  # POST /payroll_settings
  # POST /payroll_settings.json
  def create
    @payroll_setting = PayrollSetting.new(params[:payroll_setting])

    respond_to do |format|
      if @payroll_setting.save
        format.html { redirect_to @payroll_setting, notice: 'Payroll setting was successfully created.' }
        format.json { render json: @payroll_setting, status: :created, location: @payroll_setting }
      else
        format.html { render action: "new" }
        format.json { render json: @payroll_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /payroll_settings/1
  # PUT /payroll_settings/1.json
  def update
    @payroll_setting = PayrollSetting.find(params[:id])

    respond_to do |format|
      if @payroll_setting.update_attributes(params[:payroll_setting])
        format.html { redirect_to @payroll_setting, notice: 'Payroll setting was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @payroll_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payroll_settings/1
  # DELETE /payroll_settings/1.json
  def destroy
    @payroll_setting = PayrollSetting.find(params[:id])
    @payroll_setting.destroy

    respond_to do |format|
      format.html { redirect_to payroll_settings_url }
      format.json { head :ok }
    end
  end
 
end
