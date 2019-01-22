class TdsPaymentVouchersController < ApplicationController
  before_filter :menu_title
  # GET /tds_payment_vouchers
  # GET /tds_payment_vouchers.json
  def index
    @search = @company.tds_payment_vouchers.by_branch_id(@current_user.branch_id).by_date(@financial_year).search(params[:search])
    @tds_payment_vouchers = @search.order("payment_date DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => TdsPaymentVoucherDatatable.new(view_context, @company, @current_user,@financial_year) }
    end
  end

  # GET /tds_payment_vouchers/1
  # GET /tds_payment_vouchers/1.json
  def show
    @tds_payment_voucher = TdsPaymentVoucher.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @tds_payment_voucher }
    end
  end

  # GET /tds_payment_vouchers/new
  # GET /tds_payment_vouchers/new.json
  def new
    @tds_payment_voucher = TdsPaymentVoucher.new_tds_payment(params)
    @from_accounts = Account.get_tds_payable_accounts(@company)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @tds_payment_voucher }
    end
  end

  # GET /tds_payment_vouchers/1/edit
  def edit
    @tds_payment_voucher = TdsPaymentVoucher.find(params[:id])
    @payment_detail = @tds_payment_voucher.payment_detail
    @from_accounts = Account.get_tds_payable_accounts(@company)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')

  end

  # POST /tds_payment_vouchers
  # POST /tds_payment_vouchers.json
  def create
    @tds_payment_voucher = TdsPaymentVoucher.create_tds_payment(params, @company.id, @current_user, @financial_year.year.name)

    respond_to do |format|
      if @tds_payment_voucher.valid?
        @tds_payment_voucher.save_with_ledgers
        @tds_payment_voucher.register_user_action(request.remote_ip, 'created')

        format.html { redirect_to @tds_payment_voucher, :notice => 'Tds payment voucher was successfully created.' }
        format.json { render :json => @tds_payment_voucher, :status => :created, :location => @tds_payment_voucher }
      else
        @from_accounts = Account.get_tds_payable_accounts(@company)
        @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')
        @payment_detail = PaymentVoucher.fetch_payment_details(params)

        format.html { render :action => "new" }
        format.json { render :json => @tds_payment_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tds_payment_vouchers/1
  # PUT /tds_payment_vouchers/1.json
  def update
    @tds_payment_voucher = TdsPaymentVoucher.update_tds_payment(params, @company.id, @current_user, @financial_year.year.name)
    @from_accounts = Account.get_tds_payable_accounts(@company)
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')

    respond_to do |format|
       @tds_payment_voucher.update_attributes(params[:tds_payment_voucher])
      if @tds_payment_voucher.valid?
        @tds_payment_voucher.update_and_post_ledgers
        @tds_payment_voucher.register_user_action(request.remote_ip, 'updated')

        format.html { redirect_to @tds_payment_voucher, :notice => 'Tds payment voucher was successfully updated.' }
        format.json { head :ok }
      else
        @payment_detail = PaymentVoucher.fetch_payment_details(params)
        format.html { render :action => "edit" }
        format.json { render :json => @tds_payment_voucher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tds_payment_vouchers/1
  # DELETE /tds_payment_vouchers/1.json
  def destroy
    @tds_payment_voucher = TdsPaymentVoucher.find(params[:id])
    @tds_payment_voucher.destroy
    @tds_payment_voucher.register_user_action(request.remote_ip, 'deleted')

    respond_to do |format|
      format.html { redirect_to tds_payment_vouchers_url ,:notice => "Voucher deleted successfully"}
      format.json { head :ok }
    end
  end
#method for partial.js(ajax)
  def payment_mode

  end


  def menu_title
    @menu = 'Expenses'
    @page_name = 'TDS Payment'
  end
end
