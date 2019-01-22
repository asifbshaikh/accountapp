class VoucherTitlesController < ApplicationController

  def new
    @voucher_title = VoucherTitle.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @voucher_title }
    end
  end

  # GET /custom_fields/1/edit
  def edit
    @voucher_title = VoucherTitle.find(params[:id])
  end

  # POST /custom_fields
  # POST /custom_fields.xml
  def create
    @voucher_title = VoucherTitle.create_record(params, @company.id)
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
    respond_to do |format|
      if @voucher_title.save
        @voucher_title.register_user_action(@current_user.id, request.remote_ip, 'created', @current_user.branch_id)
      end
      format.js {render "settings/create_title"}
    end
  end

  # PUT /custom_fields/1
  # PUT /custom_fields/1.xml
  def update
    @voucher_title = VoucherTitle.find(params[:id])
    respond_to do |format|
      if @voucher_title.update_attributes(params[:voucher_title])
        @voucher_title.register_user_action(@current_user.id,request.remote_ip, 'updated', @current_user.branch_id)
         format.html { redirect_to(@voucher_title, :notice => 'Title successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@voucher_title) }
      end
    end
  end

  # DELETE /custom_fields/1
  # DELETE /custom_fields/1.xml
  def destroy
    @voucher_title = VoucherTitle.find(params[:id])
    @voucher_title.destroy
    @voucher_title.register_user_action(@current_user.id, request.remote_ip, 'deleted', @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to("/settings/invoice_setting", :notice => "Voucher title for invoice has been deleted successfully") }
      format.xml  { head :ok }
    end
  end

end
