class AccountHeadsController < ApplicationController
  # GET /account_heads
  # GET /account_heads.xml
  def index
    # @account_heads = AccountHead.where(:company_id => @company.id, :deleted => false).order("created_at DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => AccountHeadDatatable.new(view_context, @company, @current_user, @financial_year)}
    end
  end

  # GET /account_heads/1
  # GET /account_heads/1.xml
  def show
    @menu = 'Settings'
    @page_name = 'Account groups'
    @account_head = AccountHead.find(params[:id])
    @accounts = Account.find_all_by_account_head_id_and_company_id(params[:id],@company.id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account_head }
    end
  end

  # GET /account_heads/new
  # GET /account_heads/new.xml
  def new
    @menu = 'Settings'
    @page_name = 'Account groups'
    @account_heads = @company.account_heads.by_deleted(false).where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','Duties and Taxes')")
    @account_head = AccountHead.new
    @account_head.parent_id = params[:parent_id].to_i unless params[:parent_id].nil?

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account_head }
    end
  end

  # GET /account_heads/1/edit
  def edit
    @menu = 'Settings'
    @page_name = 'Account groups'
    @account_heads = @company.account_heads.by_deleted(false).where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','Duties and Taxes')")
    @account_head = AccountHead.find(params[:id])
  end

  # POST /account_heads
  # POST /account_heads.xml
  def create
    @account_head = AccountHead.new(params[:account_head])
    @account_head.company = @company
    @account_head.created_by = session[:current_user_id]
    respond_to do |format|
      if @account_head.save
        Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " new #{@account_head.name} for #{@company.name}", "created", @current_user.branch_id)
        format.html { redirect_to(@account_head, :notice => 'Account head was successfully created.') }
        format.xml  { render :xml => @account_head, :status => :created, :location => @account_head }
      else
        @menu = 'Settings'
        @page_name = 'Account groups'
        @account_heads = @company.account_heads.by_deleted(false).where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','Duties and Taxes')")
        format.html { render :action => "new" }
        format.xml  { render :xml => @account_head.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /account_heads/1
  # PUT /account_heads/1.xml
  def update
    @account_head = AccountHead.find(params[:id])
    @account_heads = @company.account_heads.by_deleted(false).where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','Duties and Taxes')")
    respond_to do |format|
      if @account_head.update_attributes(params[:account_head])
        Workstream.register_user_action( @company.id, @current_user.id, request.remote_ip,
        "#{@account_head.name} #{@company.name}", "updated", @current_user.branch_id)
        format.html { redirect_to(@account_head, :notice => 'Account head was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Settings'
        @page_name = 'Accounts groups'
        # @account_heads = AccountHead.where(:company_id => @company.id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account_head.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /account_heads/1
  # DELETE /account_heads/1.xml
  def destroy
    @account_head = AccountHead.find(params[:id])
    if @account_head.has_account?
      flash[:error] = "There are accounts still relating to #{@account_head.name}. Please delete them before deleting the account head."
      redirect_to :back
    else
      @account_head.destroy
       Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
       " #{@account_head.name} of #{@company.name} is marked for deletion", "deleted", @current_user.branch_id)
         flash[:success] = "Account head has been deleted successfully"
         redirect_to account_heads_path

    end
  end
end
