class SettingsController < ApplicationController
  def index
  end

  def edit
    @company.old_file_size = @company.logo_file_size
    @countries = Country.all
    @states = State.all
    @currencies = Currency.all
	  if @company.address.blank?
	    @company.build_address
	  end
  
  end

  def show
    @payroll_settings = PayrollSetting.find_by_company_id(@company.id)
    @gst_categories = GstCategory.all
    #[USE] used for Instamojo Payment key and CashFree
    @key_history=InstamojoPayments.where(:company_id => @company.id).order("created_at desc").limit(1)
    @cfkey_history=CashFreeSetting.where(:company_id => @company.id).order("created_at desc").limit(1)
		# [OPTIMIZE] We are fetching data for all tabs here. Need to ajax it a bit.
    @warehouse = Warehouse.new
    @country_company = @company.country
    @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
    @product_setting = @company.product_setting
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    @invoice_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @label = @company.label
    @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
    @departments = @company.departments
    @designations = @company.designations
    @holidays = @company.holidays
    @leave_types = @company.leave_types
    @company.old_file_size = @company.logo_file_size
    @countries = Country.all
    @states = State.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
    @branches = @company.branches
    @branch = Branch.new
    @department = Department.new
    @designation = Designation.new
    @holiday = Holiday.new
    @leave_type = LeaveType.new
    @voucher_title = VoucherTitle.new
    respond_to do |format|
      format.html
    end
  end


def load_form
  @payroll_settings = PayrollSetting.find_by_company_id(@company.id)
  @gst_categories = GstCategory.all
    #[USE] used for Instamojo Payment key and CashFree
    @key_history=InstamojoPayments.where(:company_id => @company.id).order("created_at desc").limit(1)
    @cfkey_history=CashFreeSetting.where(:company_id => @company.id).order("created_at desc").limit(1)
    # [OPTIMIZE] We are fetching data for all tabs here. Need to ajax it a bit.
    @warehouse = Warehouse.new
    @country_company = @company.country
    @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
    @product_setting = @company.product_setting
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    @invoice_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @label = @company.label
    @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
    @departments = @company.departments
    @designations = @company.designations
    @holidays = @company.holidays
    @leave_types = @company.leave_types
    @company.old_file_size = @company.logo_file_size
    @states = State.all   
    @countries = Country.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
    @branches = @company.branches
    @branch = Branch.new
    @department = Department.new
    @designation = Designation.new
    @holiday = Holiday.new
    @leave_type = LeaveType.new
    @voucher_title = VoucherTitle.new
end

  def invoice_setting
    @warehouse = Warehouse.new
    @payroll_settings = PayrollSetting.find_by_company_id(@company.id)
    @country_company = @company.country
    @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @product_setting = @company.product_setting
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    @invoice_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @label = @company.label
    @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
    @departments = @company.departments
    @designations = @company.designations
    @holidays = @company.holidays
    @leave_types = @company.leave_types
    @company.old_file_size = @company.logo_file_size
    @countries = Country.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
    @branches = @company.branches
    @branch = Branch.new
    @department = Department.new
    @designation = Designation.new
    @holiday = Holiday.new
    @leave_type = LeaveType.new
    @voucher_title = VoucherTitle.new
    respond_to do |format|
      format.html
    end
  end

  def gstr_advance_payment_setting
    @warehouse = Warehouse.new
    @payroll_settings = PayrollSetting.find_by_company_id(@company.id)
    @country_company = @company.country
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"GstrAdvancePayment")
    @templates = Template.where(:voucher_type => "GstrAdvancePayment", :deleted=> false)
    @gstr_advance_payment_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "GstrAdvancePayment")
    @product_setting = @company.product_setting
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    @label = @company.label
    @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
    @departments = @company.departments
    @designations = @company.designations
    @holidays = @company.holidays
    @leave_types = @company.leave_types
    @company.old_file_size = @company.logo_file_size
    @countries = Country.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
    @branches = @company.branches
    @branch = Branch.new
    @department = Department.new
    @designation = Designation.new
    @holiday = Holiday.new
    @leave_type = LeaveType.new
    @voucher_title = VoucherTitle.new
    respond_to do |format|
      format.html
    end
  end
def gstr_advance_receipt_setting
    @warehouse = Warehouse.new
    #@company = Company.find_by_subdomain(request.subdomain)
    @country_company = @company.country
    @gstr_advance_receipt_setting = GstrAdvanceReceiptSetting.find_by_company_id(@company.id)
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @gstr_advance_receipt_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @product_setting = @company.product_setting
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    @invoice_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @label = @company.label
    @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
    @departments = @company.departments
    @designations = @company.designations
    @holidays = @company.holidays
    @leave_types = @company.leave_types
    @company.old_file_size = @company.logo_file_size
    @countries = Country.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
    @branches = @company.branches
    @branch = Branch.new
    @department = Department.new
    @designation = Designation.new
    @holiday = Holiday.new
    @leave_type = LeaveType.new
    @voucher_title = VoucherTitle.new
    respond_to do |format|
      format.html
    end
  end

  # def custom_field
  #   @warehouse = Warehouse.new
  #   @country_company = @company.country
  #   @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
  #   @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
  #   @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
  #   @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
  #   @product_setting = @company.product_setting
  #   @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
  #   @invoice_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
  #   @label = @company.label
  #   @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
  #   @departments = @company.departments
  #   @designations = @company.designations
  #   @holidays = @company.holidays
  #   @leave_types = @company.leave_types
  #   @company.old_file_size = @company.logo_file_size
  #   @countries = Country.all
  #   @currencies = Currency.all
  #   if @company.address.blank?
  #     @company.build_address
  #   end
  #   @branches = @company.branches
  #   @branch = Branch.new
  #   @department = Department.new
  #   @designation = Designation.new
  #   @holiday = Holiday.new
  #   @leave_type = LeaveType.new
  #   @voucher_title = VoucherTitle.new
  #   respond_to do |format|
  #     format.html
  #   end
  # end

  def customfield
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
  end

  def payroll
    @warehouse = Warehouse.new
    @payroll_settings = PayrollSetting.find_by_company_id(@company.id)
    @country_company = @company.country
    @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @product_setting = @company.product_setting
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    @invoice_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @label = @company.label
    @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
    @departments = @company.departments
    @designations = @company.designations
    @holidays = @company.holidays
    @leave_types = @company.leave_types
    @company.old_file_size = @company.logo_file_size
    @countries = Country.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
    @branches = @company.branches
    @branch = Branch.new
    @department = Department.new
    @designation = Designation.new
    @holiday = Holiday.new
    @leave_type = LeaveType.new
    @voucher_title = VoucherTitle.new
    respond_to do |format|
      format.html
    end
  end

  def inventory
    @payroll_settings = PayrollSetting.find_by_company_id(@company.id)
    @key_history=InstamojoPayments.where(:company_id => @company.id).order("created_at desc").limit(1)
    @cfkey_history=CashFreeSetting.where(:company_id => @company.id).order("created_at desc").limit(1)
    @warehouse = Warehouse.new
    @country_company = @company.country
    @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @product_setting = @company.product_setting
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    @invoice_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @label = @company.label
    @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
    @departments = @company.departments
    @designations = @company.designations
    @holidays = @company.holidays
    @leave_types = @company.leave_types
    @company.old_file_size = @company.logo_file_size
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
    @countries = Country.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
    @branches = @company.branches
    @branch = Branch.new
    @department = Department.new
    @designation = Designation.new
    @holiday = Holiday.new
    @leave_type = LeaveType.new
    @voucher_title = VoucherTitle.new
    respond_to do |format|
      format.html
    end
  end

  def freeze_fin_year
    @warehouse = Warehouse.new
    @country_company = @company.country
    @invoice_setting = InvoiceSetting.find_by_company_id(@company.id)
    @templates = Template.where(:voucher_type => "Invoice", :deleted=> false)
    @invoice_template = CompanyTemplate.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @product_setting = @company.product_setting
    # @custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, params[:voucher_type])
    @invoice_custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, "Invoice")
    @label = @company.label
    @financial_years = FinancialYear.joins(:year).order("years.name").where(:company_id => @company.id)
    @departments = @company.departments
    @designations = @company.designations
    @holidays = @company.holidays
    @leave_types = @company.leave_types
    @company.old_file_size = @company.logo_file_size
    @voucher_titles = VoucherTitle.where(:company_id=> @company.id, :voucher_type=>"Invoice")
    @countries = Country.all
    @currencies = Currency.all
    if @company.address.blank?
      @company.build_address
    end
    @branches = @company.branches
    @branch = Branch.new
    @department = Department.new
    @designation = Designation.new
    @holiday = Holiday.new
    @leave_type = LeaveType.new
    @voucher_title = VoucherTitle.new
    respond_to do |format|
      format.html
    end
  end
  
  def freeze_year
    financial_year = FinancialYear.find_by_company_id_and_id(@company.id, params[:id].to_i)
    FinancialYearLog.create_log(financial_year, @current_user.id, 1)
    if !financial_year.blank? && financial_year.freez_financial_year
      financial_year.register_user_action(request.remote_ip, "updated", "frozen", @current_user)
      flash[:success] = "Successfully freezed financial year..."
      redirect_to "/settings/freeze_fin_year"
    else
      flash[:error] = "something went wrong"
      redirect_to :back
    end
  end

  def unfreeze_fin_year
    financial_year = FinancialYear.find params[:id]
    FinancialYearLog.create_log(financial_year, @current_user.id, 2)
    if financial_year.unfreeze
      financial_year.register_user_action(request.remote_ip, "updated", "unfreeze", @current_user)
      flash[:success] = "Financial year unfreeze successfully"
      redirect_to "/settings/freeze_fin_year"
    end
  end

def edit_logo
    data_logo = nil
    @company = Company.find(params[:id])
  end
  def update_logo
    @is_save = false
    @company = Company.find(params[:id])
    if @company.update_attribute(params[:company])
    @is_save = true
    else
    @is_save= false
   end
  end

  def set_voucher_sequence
    voucher_setting = VoucherSetting.where(:company_id=> @company.id, :voucher_type=> params[:voucher_type]).first
    customfield_voucher_type = CustomField.get_voucher_type(params[:voucher_type].to_i)
    custom_field = CustomField.find_by_company_id_and_voucher_type(@company.id, customfield_voucher_type)
    voucher_setting.change_voucher_number_strategy(params)
    if !custom_field.blank?
      custom_field.update_with_strategy(params)
    end
    flash[:success]="Voucher number strategy was changed."
    redirect_to "/settings/show#customfield"
  end

 def cashfree_file
  @cashfreefile = CashfreeDocument.cashfree_file(params, @company, @current_user)

    if @cashfreefile.save
      mail_to = 'care@gocashfree.com'
      bcc = 'naveen@thenextwave.in,harshal@profitbooks.net'
      subject = "Request for activating CashFree Account."
      @email_valid = validate_email?(mail_to)
      if  @email_valid
        Email.send_cashfree_docs(@cashfreefile,@company, @current_user, subject,mail_to, bcc).deliver
      end
       flash[:success]="Your request for CashFree has been submitted successfully."
     redirect_to  settings_show_path
    else
      # format.js
    end
  # end
 end

 def enable_gateway
 status= @company.invoice_setting
 if params[:enable_gateway].present?
    status.update_attributes(:enable_gateway=>params[:enable_gateway])
  else
     status.update_attributes(:enable_cashfree=>params[:enable_cashfree])
  end
 render :nothing=> true
 
 end

 def enable_payslip_signatory
      @payroll_settings = PayrollSetting.find_by_company_id(@company.id)
      @payroll_settings.update_attributes(:enable_payslip_signatory=>params[:enable_payslip_signatory])
      render :nothing=> true
  end

end
