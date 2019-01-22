class DutiesAndTaxesController < ApplicationController
  helper_method :sort_column, :sort_direction
  def index
    @accounts = Account.get_non_tds_tax_accounts(@company, params[:page], "#{sort_column} #{sort_direction}")
  end

  def show
    @account = @company.accounts.find(params[:id])
  end

  def new
  end

  def edit
    @account = @company.accounts.find(params[:id])
  end

  def create
    if Account.create_tax(params, @company.id, @current_user)
      flash.now[:success] = "Tax was created successfully"
      redirect_to "/duties_and_taxes/index"
    else
      flash.now[:error] = "Fields with red * are mandatory"
      render :new
    end
  end

  def update

  end

  def add_row

  end

  def destroy
    @account = @company.accounts.find(params[:id])
    if @account.has_ledgers? || @account.has_vouchers? || @account.has_payheads?
      flash.now[:error] = "There are vouchers still relating to #{@account.name}. Please delete them before deleting the accounts."
      redirect_to :back
    else
      @account.destroy
      Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " #{@account.accountable_type} #{@account.name} is marked for deletion", "deleted", @current_user.branch_id)
      flash.now[:success] = "Tax was deleted successfully"
      redirect_to '/duties_and_taxes/index'
    end
  end

  def report
    @tax_accounts = Account.where(:company_id => @company.id, :accountable_type => ["DutiesAndTaxesAccounts", "OtherCurrentAsset"])
    @tax_account = params[:account_id].blank? ? @tax_accounts.first : @company.accounts.find_by_id(params[:account_id])
    @customer_vendor = TransactionType.fetch_to_accounts(@company.id, 'sales')
    @cv_account = @company.accounts.find_by_id(params[:id]) unless params[:id].blank?
    #@account = (params[:account_id].nil?)? @accounts.first : @accounts.find(params[:account_id])
    @start_date = params[:start_date].blank? ? @financial_year.start_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.current.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i

    unless @customer_vendor.blank? || @tax_accounts.blank?
      @ledgers = Ledger.get_record(@start_date, @end_date, @branch_id, @financial_year, @current_user, @tax_account)
    end
  end

  def tax_report
    @start_date = start_date(params)
    @end_date = end_date(params) #
    @tax_accounts=Account.get_tax_report_tax_accounts(@company.id)
    @tax_hash = {}
    @tax_accounts.each { |account| @tax_hash["#{account.name}"]=0 }
    @ledgers = @company.ledgers.includes(:account).includes(:voucher).by_account(@tax_accounts.map{ |a| a.id }).by_date_range(@start_date, @end_date).order("transaction_date ASC")
    respond_to do |format|
      format.html
      format.xls
      format.pdf do
        pdf=TaxSummaryReport.new(view_context, @company, @ledgers, @tax_hash, @start_date, @end_date)
        send_data pdf.render, :filename=>"tax_summary_report.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
    end
  end

  def vat_report
    @start_date = start_date(params)
    @end_date = end_date(params) #params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @vat_accounts = Account.get_vat_accounts(@company.id)
    @vat_hash = {}
    @vat_accounts.each { |account| @vat_hash["#{account.name}"]=0 }

    @sales_ledgers = @company.ledgers.by_account(@vat_accounts.map{ |a| a.id }).by_date_range(@start_date, @end_date).sales_vouchers.includes(:account).includes(:voucher)
    @purchase_ledgers = @company.ledgers.by_account(@vat_accounts.map{ |a| a.id }).by_date_range(@start_date, @end_date).purchase_vouchers.includes(:account).includes(:voucher)
    @other_ledgers = @company.ledgers.by_account(@vat_accounts.map{ |a| a.id }).by_date_range(@start_date, @end_date).other_vouchers.includes(:account).includes(:voucher)
    respond_to do |format|
      format.html
      format.xls
      format.pdf do
        pdf=VatSummaryReport.new(view_context, @company, @sales_ledgers, @purchase_ledgers, @other_ledgers, @tax_hash, @start_date, @end_date)
        send_data pdf.render, :filename=>"vat_summary_report.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
    end
  end

  def show_modal
    @account=@company.accounts.find_by_id_and_accountable_type(params[:account], "DutiesAndTaxesAccounts")
  end

  private

    def start_date(params)
      params[:start_date].blank? ? Time.zone.now.to_date - 3.months : params[:start_date].to_date
    end

    def end_date(params)
      params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end

    def sort_column
      Account.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
end

