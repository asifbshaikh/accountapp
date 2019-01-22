class InvoiceSettingsController < ApplicationController
  require 'net/http'
  before_filter :menu_title


  # GET /invoice_settings
  # GET /invoice_settings.xml

  def index
    @invoice_settings = InvoiceSetting.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoice_settings }
    end
  end

  # GET /invoice_settings/1
  # GET /invoice_settings/1.xml
  def show
    @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invoice_setting }
    end
  end

  # GET /invoice_settings/new
  # GET /invoice_settings/new.xml
  def new
    @invoice_setting = InvoiceSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invoice_setting }
    end
  end

  # GET /invoice_settings/1/edit
  def edit
    @invoice_setting = InvoiceSetting.find(params[:id])
  end

  # POST /invoice_settings
  # POST /invoice_settings.xml
  def create
    @invoice_setting = InvoiceSetting.new(params[:invoice_setting])

    respond_to do |format|
      if @invoice_setting.save
        format.html { redirect_to(@invoice_setting, :notice => 'Invoice setting was successfully created.') }
        format.xml  { render :xml => @invoice_setting, :status => :created, :location => @invoice_setting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @invoice_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invoice_settings/1
  # PUT /invoice_settings/1.xml
  def update
    @invoice_setting = InvoiceSetting.find(params[:id])

    respond_to do |format|
      if @invoice_setting.update_attributes(params[:invoice_setting])
        format.html { redirect_to(settings_invoice_setting_path, :notice => 'Invoice setting was successfully updated.') }
        format.json { head :ok }
        format.js {render "change_invoice_setting" }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invoice_setting.errors, :status => :unprocessable_entity }
        format.json { respond_with_bip(@custom_field) }
        format.js {render "change_invoice_setting" }
      end
    end
  end

  # DELETE /invoice_settings/1
  # DELETE /invoice_settings/1.xml
  def destroy
    @invoice_setting = InvoiceSetting.find(params[:id])
    @invoice_setting.destroy

    respond_to do |format|
      format.html { redirect_to(invoice_settings_url) }
      format.xml  { head :ok }
    end
  end
  def change_template
    @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @invoice_template.update_template(params[:company_template][:template_id])
    # respond_to do |format|
    #   if @invoice_template.update_template(params[:company_template][:template_id])
    #     format.html { redirect_to(settings_invoice_setting_path, :notice => 'Invoice template has been changed successfully.') }
    #     format.xml  { head :ok }
    #     format.js{ render ""}
    #   else
    #     format.html {redirect_to :back}
    #     flash[:error] = "Something went wrong"
    #     format.js{ render ""}
    #   end
    # end

  end

  def template_margin
    @templates = CompanyTemplate.where(:voucher_type => "Invoice", :company_id=>@company.id).first

    margin = TemplateMargin.find_by_template_id_and_company_id(@templates.template_id,@company.id)
    margin.hide_logo=params[:hide_logo]
    margin.hide_address =params[:hide_address]
    margin.top_margin =params[:top_margin].to_i*4
    margin.left_margin =params[:left_margin].to_i*4
    margin.right_margin =params[:right_margin].to_i*4
    margin.HideRateQuantity =params[:HideRateQuantity]
    if margin.top_margin == 0
      margin.top_margin =10
    end
    if margin.left_margin == 0 
      margin.left_margin =10 
    end
    if margin.right_margin == 0  
        margin.right_margin =20
    end     
     
    margin.save!


   
  end

  def instamojo_settings

      headers={'X-Api-Key'=> params[:paysetting][:apikey],'X-Auth-Token'=> params[:paysetting][:authkey]}
      puts params[:paysetting][:accounts]
      puts params[:paysetting][:authkey]
      data={} 
      url = URI.parse("https://www.instamojo.com/api/1.1/debug/")
      req = Net::HTTP::Get.new(url.request_uri,headers)
      req.set_form_data(data)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == "https")
      http.read_timeout = 180
      response = http.request(req)

      puts response.body
      result = JSON.parse response.body
      if result["success"].to_s == "true"
        account_name =result["message"][16..26].to_s
        @instapay=InstamojoPayments.add_key(params,account_name)
        if @instapay
         Workstream.register_user_action(@company.id, @current_user.id,request.remote_ip,"Configured payment gateway", "Created",nil)
        flash[:success] = 'Instamojo payment gateway configured successfully.'
        end
        @valid_key=true
      else
        @valid_key=false
      end 
  end

  def cashfree_settings
      data={'appId'=> params[:cashfreesetting][:appid],'secretKey'=> params[:cashfreesetting][:secretkey],'name'=> 'pc',
      'value'=>'CFM002'}
      url = URI.parse("https://api.gocashfree.com/api/v1/credentials/verify")
      # url = URI.parse("https://test.gocashfree.com/api/v1/credentials/verify")
      req = Net::HTTP::Post.new(url.request_uri)
      req.set_form_data(data)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == "https")
      response = http.request(req)
      puts response.body
      result = JSON.parse response.body
      puts result["status"]
      result = JSON.parse response.body
      if result["status"].to_s == "OK"
        @cashfree=CashFreeSetting.add_key(params)
        if @cashfree
         Workstream.register_user_action(@company.id, @current_user.id,request.remote_ip,"Configured CashFree payment gateway", "Created",nil)
        flash[:success] = 'CashFree payment gateway configured successfully.'
        end
        @valid_key=true
      else
        @valid_key=false
      end 
  end



  private

    def menu_title
      @menu = 'Invoice Settings'
      @page_name = 'Details'
    end
end
