class ReceiptVouchersController < ApplicationController
 rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # GET /receipt_vouchers
  # GET /receipt_vouchers.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => ReceiptVoucherDatatable.new(view_context, @company, @current_user, @financial_year) }
      format.json  { render :json => IncomeVouchersDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  def deleted_receipt_voucher
    @search = @company.receipt_vouchers.by_branch_id(@current_user.branch_id).by_deleted(true).by_date(@financial_year).search(params[:search])
    @receipt_vouchers = @search.order("voucher_date DESC").page(params[:page]).per(20)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @receipt_vouchers}
    end
  end

  # GET /receipt_vouchers/1
  # GET /receipt_vouchers/1.xml
  def show
    @receipt_voucher = @company.receipt_vouchers.find(params[:id])
    @currency = @company.currency_code
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        pdf=ReceiptPdf.new(@receipt_voucher, view_context, @company)
        send_data pdf.render, :filename=>"#{@receipt_voucher.voucher_number}.pdf", :disposition=>"inline", :type=>'application/pdf'
      end
      format.xml  { render :xml => @receipt_voucher }
    end
  end

  # GET /receipt_vouchers/new
  # GET /receipt_vouchers/new.xml
  def new
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @receipt_voucher = ReceiptVoucher.new_receipt(params, @company, @current_user, @from_accounts.first)
    @projects = @company.projects.where(:status => false)
    # @invoices = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_customer(@from_accounts.first.id).by_currency(@from_accounts.first.get_currency_id)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
    @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
    @income_voucher = IncomeVoucher.new_income(@company)
    @other_income_from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @other_income_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')
    @other_income_from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
    @other_income_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @receipt_voucher }
    end
  end

  # GET /receipt_vouchers/1/edit
  def edit
    @projects = @company.projects.where(:status => false)
    @receipt_voucher = @company.receipt_vouchers.find(params[:id])
    # @invoices = @receipt_voucher.invoices
    @receipt_detail = @receipt_voucher.payment_detail
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
    @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
    @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 2)
    @income_voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 3)
  end

  # POST /receipt_vouchers
  # POST /receipt_vouchers.xml
  def create
    @receipt_voucher = ReceiptVoucher.create_receipt(params, @company, @current_user, @financial_year.year.name)
    @projects = @company.projects.where(:status => false)
    respond_to do |format|
      if @receipt_voucher.valid?
        VoucherSetting.next_receipt_voucher_write(@company)
        @receipt_voucher.save_with_ledgers
        @receipt_voucher.update_included_invoice_status
        @receipt_voucher.register_user_action(request.remote_ip, 'created')
        @receipt_voucher.create_invoice_histories
        format.js {render "/invoices/add_payment"}
        format.html { redirect_to(@receipt_voucher, :notice => 'Receipt voucher was successfully created.') }
        format.xml  { render :xml => @receipt_voucher, :status => :created, :location => @receipt_voucher }
      else
        @receipt_voucher.voucher_number = VoucherSetting.next_receipt_voucher_number(@company)
        # @invoices = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_customer(@receipt_voucher.from_account_id).by_currency(@receipt_voucher.from_account.get_currency_id)
        invoices=@company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_customer(@receipt_voucher.from_account_id)
        customer = @receipt_voucher.get_party
        if !customer.blank? && !customer.currency.blank? && customer.currency != @company.currency_code
          invoices=invoices.by_currency(@receipt_voucher.currency_id)
        end
        invoices.each do |invoice|
          if @receipt_voucher.invoices_receipts.where(:invoice_id=>invoice.id).blank?
            invoice_receipt=InvoicesReceipt.new(:invoice_id=>invoice.id, :tds_amount=>nil, :amount=>nil)
            @receipt_voucher.invoices_receipts<<invoice_receipt
          end
        end
        @projects = @company.projects.where(:status => false)
        @receipt_detail = @receipt_voucher.payment_detail
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
        @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
        @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)

        @income_voucher = IncomeVoucher.new_income(@company)
        @other_income_from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
        @other_income_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')
        @other_income_from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
        @other_income_to_account_heads = AccountHead.get_contra_to_heads(@company.id)
        @tds_receivable = Account.find_by_name_and_company_id("tds receivable", @company.id).id
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 2)
        @income_voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 3)
        format.js {render "/invoices/add_payment"}
        format.html { render :action => "new" }
        format.xml  { render :xml => @receipt_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end
  # PUT /receipt_vouchers/1
  # PUT /receipt_vouchers/1.xml
  def update
    @receipt_voucher = ReceiptVoucher.update_receipt(params, @company.id, @current_user, @financial_year.year.name)
    @projects = @company.projects.where(:status => false)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
    @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
    respond_to do |format|
      if @receipt_voucher.valid?
        @receipt_voucher.save!
        @receipt_voucher.update_and_post_ledgers
        @receipt_voucher.reload
        @receipt_voucher.set_amount_allocation if @receipt_voucher.advanced?
        @receipt_voucher.update_included_invoice_status
        @receipt_voucher.register_user_action(request.remote_ip, 'updated')
        format.html { redirect_to(@receipt_voucher, :notice => 'Receipt voucher was successfully updated.') }
        format.xml  { head :ok }
      else
        # @invoices = @receipt_voucher.invoices
        @projects = @company.projects.where(:status => false)
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'receipts')
        @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
        @from_account_heads = AccountHead.get_receipt_from_heads(@company.id)
        @to_account_heads = AccountHead.get_receipt_to_heads(@company.id)
        @customer_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
        @receipt_detail = @receipt_voucher.payment_detail
        @voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 2)
        @income_voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(@company.id, 3)
        if !params[:back_action].blank? && params[:back_action]=="allocate"
          @allocated_invoices=@receipt_voucher.invoices_receipts
          @unallocated_invoices=@company.invoices.not_in(@allocated_invoices).by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_customer(@receipt_voucher.from_account_id).by_currency(@receipt_voucher.currency_id)
          format.html { render :action => "allocate" }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @receipt_voucher.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  #soft delete vouchers
  def destroy
    @receipt_voucher = @company.receipt_vouchers.find(params[:id])
    ActiveRecord::Base.transaction do
      @receipt_voucher.invoices.update_all(:invoice_status_id=>0)
      @receipt_voucher.destroy
    end
    respond_to do |format|
      @receipt_voucher.register_delete_action(request.remote_ip, @current_user, 'deleted')
      format.html { redirect_to(receipt_vouchers_url, :notice => "receipt voucher has been successfully deleted") }
    end
  end

  def payment_mode
  end

  def add_deposit_to_account
    @account_heads = AccountHead.get_receipt_to_heads(@company.id)
  end
  def account_partial
    @account_head = AccountHead.find(params[:account_head_id]) unless params[:account_head_id].blank?
  end

  def search_invoice
    @from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @customer_accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    srange = nil
    erange = nil
    if !params[:invoice_amount].blank?
      if params[:invoice_amount].to_i == 1
        srange = 0
        erange = 5000
      elsif params[:invoice_amount].to_i == 2
        srange = 5000
        erange = 50000
      elsif params[:invoice_amount].to_i == 3
        srange = 50000
        erange = 100000
      elsif params[:invoice_amount].to_i == 4
        srange = 100000
      end

    end
    customer = @company.accounts.find_by_id(params[:account_id])
    if customer.blank?
     @inv_nos = @company.invoices.where(:invoice_status_id => 0, :deleted => false, :invoice_date => (params[:from_date].blank? ? @financial_year.start_date : params[:from_date].to_date)..(params[:to_date].blank? ? @financial_year.end_date : params[:to_date].to_date))
    else
     @inv_nos = @company.invoices.where(:invoice_status_id => 0, :deleted => false, :invoice_date => (params[:from_date].blank? ? @financial_year.start_date : params[:from_date].to_date)..(params[:to_date].blank? ? @financial_year.end_date : params[:to_date].to_date), :account_id => customer.id)
    end
    @inv_nos1= @inv_nos
    unless srange.blank? || erange.blank?
      @inv_nos = []
      @inv_nos1.each do |inv|
        if inv.amount >= srange && inv.amount <= erange
          @inv_nos<<inv
        end
      end
    end
    if !srange.blank? && erange.blank?
      @inv_nos = []
      @inv_nos1.each do |inv|
        if inv.amount >= srange
          @inv_nos<<inv
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def create_email
    @receipt_voucher = @company.receipt_vouchers.find(params[:id])
  end

  def email_receipt_voucher
    receipt_voucher = @company.receipt_vouchers.find(params[:id])

    # template = File.read("#{Rails.root.to_s}/app/views/receipt_vouchers/show.pdf.prawn")
    # pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')

    #  pdf.instance_eval do
    #   @company = current_company
    #   @receipt_voucher = receipt_voucher
    #   @currency = current_company.currency_code
    #   eval(template) #this evaluates the template with your variables
    # end
    # attachment = pdf.render
    # @company = current_company
    # @receipt_voucher = @company.receipt_vouchers.find(params[:id])

    mail_to = params[:email]
    mail_to =mail_to.gsub(/\s+/, " ").strip
    subject = params[:subject]
    text = params[:text]
    @email_valid = validate_email?(mail_to)
    logger.debug "+++++++++++++++++++email valid #{@email_valid}"
    if @email_valid
      pdf = ReceiptPdf.new(receipt_voucher, view_context, @company)
      attachment=pdf.render

      Email.send_receipt(attachment, receipt_voucher, @company, @current_user, subject, text, mail_to).deliver
      # redirect_to receipt_voucher_path(@receipt_voucher)
      flash[:success] = 'Email has been sent successfully.'
    else
      # redirect_to :back
      flash[:error]='Email is either blank or invalid.'
    end

  end

  def customer_invoices
    @customer = @company.accounts.find_by_name(params[:from_account_id])
    @cust_invoices = Invoice.get_customer_unpaid_invoices(@company, @customer)
  end

  def customer_unpaid_invoices
    account = @company.accounts.find_by_id(params[:account_id].to_i)
    @invoices = @company.invoices.by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_customer(account.id)#.by_currency(account.get_currency_id)
    customer = account.get_party
    if !customer.blank? && !customer.currency.blank? && customer.currency != @company.currency_code
      @invoices=@invoices.by_currency(customer.currency_id)
    end
  end

  def allocate
    @receipt_voucher = @company.receipt_vouchers.find(params[:id])
    # Fetching invoices related to this receipt voucher.
    @allocated_invoices=@receipt_voucher.invoices_receipts
    @unallocated_invoices=@company.invoices.not_in(@allocated_invoices).by_branch_id(@current_user.branch_id).by_deleted(false).by_status(0).by_customer(@receipt_voucher.from_account_id)
    customer = @receipt_voucher.get_party
    if !customer.blank? && !customer.currency.blank? && customer.currency != @company.currency_code
      @unallocated_invoices=@unallocated_invoices.by_currency(@receipt_voucher.currency_id)
    end
  end

  private
  def record_not_found
    flash[:error] = "It looks the record you are trying to access is not available or might be deleted"
    redirect_to :action=> :index
  end

end
