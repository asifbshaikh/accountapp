class CustomFieldsController < ApplicationController
  # GET /custom_fields
  # GET /custom_fields.xml
  def index
    @custom_fields = @company.custom_fields.page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @custom_fields }
    end
  end

  # GET /custom_fields/1
  # GET /custom_fields/1.xml
  def show
    @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    respond_to do |format|
      format.html { render "settings/custom_field" }
      format.xml  { render :xml => @custom_field }
    end
  end

  def custom_field_report
    unless params[:voucher_type].blank?
      @vouchers = params[:voucher_type].to_s.constantize.get_record_with_custom_field(params, @company, @financial_year)
      @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
      prawnto :filename => "custom_field_report.pdf"
    end
  end
  # GET /custom_fields/new
  # GET /custom_fields/new.xml
  def new
    @custom_field = CustomField.new_record(params[:voucher])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @custom_field }
    end
  end

  # GET /custom_fields/1/edit
  def edit
    @custom_field = CustomField.find(params[:id])
  end

  # POST /custom_fields
  # POST /custom_fields.xml
  def create
    @custom_field = CustomField.create_record(params, @company.id)
    respond_to do |format|
      if @custom_field.save
        @custom_field.register_user_action(@current_user.id, request.remote_ip, 'created', @current_user.branch_id)
        format.html { redirect_to("/settings/custom_field?voucher_type=#{@custom_field.voucher_type}", :notice => 'Custom field was successfully created.') }
        format.xml  { render :xml => @custom_field, :status => :created, :location => @custom_field }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @custom_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /custom_fields/1
  # PUT /custom_fields/1.xml
  def update
    @custom_field = CustomField.find(params[:id])
    respond_to do |format|
      if @custom_field.update_attributes(params[:custom_field])
        @custom_field.register_user_action(@current_user.id,request.remote_ip, 'updated', @current_user.branch_id)
        format.html { redirect_to("/settings/custom_field", :notice => 'Custom field was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@custom_field) }
      end
    end
  end

  # DELETE /custom_fields/1
  # DELETE /custom_fields/1.xml
  def destroy
    @custom_field = CustomField.find(params[:id])
    @custom_field.destroy
    @custom_field.register_user_action(@current_user.id, request.remote_ip, 'deleted', @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to("/custom_fields/show", :notice => "Custom fields for invoice has been deleted successfully") }
      format.xml  { head :ok }
    end
  end


end
