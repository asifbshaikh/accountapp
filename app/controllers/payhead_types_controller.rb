class PayheadTypesController < ApplicationController
  layout "payroll"#, :except => [:show]
  # GET /pay_heads
  # GET /pay_heads.xml
  def index
    @menu = 'Administration'
    @page_name = 'All Payhead Types'
    @users = User.users_in_company(session[:current_user_id])
    @payhead_types = PayheadType.all
    @payhead_type = PayheadType.new
    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @payhead_types }
    end
  end

  # GET /pay_heads/1
  # GET /pay_heads/1.xml
  def show
    @menu = 'Administration'
    @page_name = 'View Payhead Type '
    @payhead_type = PayheadType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payhead_type }
    end
  end

  # GET /pay_heads/new
  # GET /pay_heads/new.xml
  def new
    @menu = 'Administration'
    @page_name = 'Define Payhead Type'
    @payhead_type = PayheadType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payhead_type }
    end
  end

  # GET /pay_heads/1/edit
  def edit
    @menu = 'Administration'
    @page_name = 'Edit Payhead Type'
    @users = User.users_in_company(session[:current_user_id])
    @payhead_type = PayheadType.find(params[:id])
  end

  # POST /pay_heads
  # POST /pay_heads.xml
  def create
    @payhead_type = PayheadType.new(params[:payhead_type])

    respond_to do |format|
      if @payhead_type.save
        @payhead_types = PayheadType.all
        @payhead_type = PayheadType.new
        format.html { redirect_to payhead_types_path }

        format.xml  { render :xml => @payhead_type, :status => :created, :location => @payhead_type }
      else
        @menu = 'Administration'
        @page_name = 'Define Payhead Type'
        format.html { render :action => "new" }
        format.xml  { render :xml => @payhead_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pay_heads/1
  # PUT /pay_heads/1.xml
  def update
    @payhead_type = PayheadType.find(params[:id])

    respond_to do |format|
      if @payhead_type.update_attributes(params[:payhead_type])
        format.html { redirect_to(@payhead_type, :notice => 'Pay head was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Administration'
        @page_name = 'Edit Payhead Type'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payhead_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pay_heads/1
  # DELETE /pay_heads/1.xml
  def destroy
    @payhead_type = PayheadType.find(params[:id])
    @payhead_type.destroy

    respond_to do |format|
      format.html { redirect_to(pay_heads_url) }
      format.xml  { head :ok }
    end
  end
end
