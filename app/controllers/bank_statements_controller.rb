class BankStatementsController < ApplicationController
  require 'date'
  require 'csv'
  require 'open-uri'
  require 'aws-sdk'
  layout "application"
  # GET /bank_statements
  # GET /bank_statements.json
  def index
    # @bank_statements = BankStatement.where(:company_id => @company.id).order("created_at DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      # format.json { render :json => @bank_statements }
      format.json { render :json => BankStatementDatatable.new(view_context,@company)}
      if !(params[:msg]).blank?
        flash[:success] = "Bank statement is created successfully."
      end
    end
  end

  # GET /bank_statements/1
  # GET /bank_statements/1.json
  def show
    @bank_statement = BankStatement.find(params[:id])
    @bank_statement_line_items = @bank_statement.bank_statement_line_items
    @account = @company.accounts.find(@bank_statement.account_id)
    @account_balance = @account.get_closing_balance(@current_user, @company.id, @financial_year,@bank_statement.end_date.to_date, @current_user.branch_id)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @bank_statement }
    end
  end

  # GET /bank_statements/new
  # GET /bank_statements/new.json
  def new
    @accounts = Account.where(:company_id => @company.id, :accountable_type => 'BankAccount')
    @bank_statement = BankStatement.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @bank_statement }
    end
  end

  # GET /bank_statements/1/edit
  def edit
    @bank_statement = BankStatement.find(params[:id])
  end

  # POST /bank_statements
  # POST /bank_statements.json

  def create
    @bank_statement = BankStatement.new(params[:bank_statement])
    bank_id = params[:bank_id].to_i
     begin
      @accounts = Account.where(:company_id => @company.id, :accountable_type => 'BankAccount')
      if BankStatement.exists?(:company_id => @company.id, :file_file_name => @bank_statement.file_file_name)
        flash.now[:error] = "File is already exists"
        respond_to do |format|
          format.html { render  :action => "new", :accounts => @accounts}
        end
      elsif @bank_statement.save
        result = BankStatement.read_file(bank_id,@bank_statement)
        if result == 1
         redirect_to :action => "statement", :id => @bank_statement.id
        elsif result == 0
          @bank_statement.destroy
          respond_to do |format|
            format.html { render  :action => "new", :accounts => @accounts}
            flash.now[:error] = "Transactions not found for selected date!"
          end
        elsif result == 2
          @bank_statement_id = @bank_statement.id
          @start_date = @bank_statement.start_date
          @end_date = @bank_statement.end_date
          @file = CSV.parse(open(@bank_statement.file.url).read)
          respond_to do |format|
          flash.now[:success]= "Bank statement is uploaded successfully, please map the columns."
          format.html{ render :action => "import", :bank_statement => @bank_statement}
        end
        end
      else
        respond_to do |format|
          format.html { render  :action => "new", :accounts => @accounts}
          format.json { render :json => @bank_statement.errors, :status => :unprocessable_entity }
        end
      end
    rescue
      @bank_statement.destroy
       respond_to do|format|
        format.html { render  :action => "new", :accounts => @accounts}
        flash.now[:error]= " We are unable to process the bank statement you have uploaded. Please contact our support desk to help us resolve this issue."
      # bank_statements
    end
  end
end
  def import
  end

  def file_import
    statement_id = params[:statement_id].to_i
    date = params[:date] 
    amount = params[:amount]
    description = params[:description]
    credit = params[:credit]
    debit = params[:debit]
    account_balance = params[:account_balance]
    @bank_statement = BankStatement.find(statement_id)
   begin
      result = BankStatement.other_bank(statement_id,date,amount,description,credit,debit,account_balance)
      if result == 0
        @bank_statement.destroy
        redirect_to :action => "new"
        flash[:error] = "Selected Date Not Found in Statement!"
      elsif result == 1
          redirect_to :action => "statement", :id => statement_id
          flash.now[:success] = "Mapping done successfully"
      end
    rescue
      @bank_statement.destroy
      redirect_to :action => "new"
      flash[:error] = "Something went wrong!"
    end
  end

  # PUT /bank_statements/1
  # PUT /bank_statements/1.json
  def update
    @bank_statement = BankStatement.find(params[:id])

    respond_to do |format|
      if @bank_statement.update_attributes(params[:bank_statement])
        format.html { redirect_to @bank_statement, :notice => 'Bank statement was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @bank_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_statements/1
  # DELETE /bank_statements/1.json
  def destroy
    @bank_statement = BankStatement.find(params[:id])
    @bank_statement_line_items = @bank_statement.bank_statement_line_items

    @bank_statement.destroy

    respond_to do |format|
      format.html { redirect_to bank_statements_url, :notice => 'Bank statement was successfully deleted.' }
      format.json { head :ok }
    end
  end
def statement_delete
    @bank_statement = BankStatement.find(params[:id])
    @accounts = Account.where(:company_id => @company.id, :accountable_type => 'BankAccount')
    @bank_statement.destroy

    respond_to do |format|
      format.html {render :action => "new",:accounts =>@accounts}
      format.json { head :ok }
    end
  end

  def statement
    @bank_statement = BankStatement.find(params[:id])
    @bank_statement_line_items = @bank_statement.bank_statement_line_items.order('date ASC')

    respond_to do |format|
      format.html
       format.json { render :json => @bank_statement, :status => :created, :location => @bank_statement }
      # flash[:success] = "Bank statement is created successfully."
    end
  end

  def match_transaction
    @deposit = Deposit.new_deposit(@company)
    @withdrawal = Withdrawal.new_record(@company)
    @income_voucher = IncomeVoucher.new_income(@company)
    @expense = Expense.new_expense(@company)
    @dep_from_accounts = TransactionType.fetch_from_accounts(@company.id,'cashacc')
    @dep_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'bankacc')
    @other_income_from_accounts = TransactionType.fetch_from_accounts(@company.id,'receipts')
    @other_income_to_accounts = TransactionType.fetch_to_accounts(@company.id, 'contra')
    @to_accounts = TransactionType.fetch_to_accounts(@company.id, 'expenseacc')
    @amount = params[:Amount].to_f
    @deposit.amount = @amount
    @withdrawal.amount = @amount
    @income_voucher.amount = @amount
    @deposit.transaction_date = params[:Transaction_date]
    @withdrawal.transaction_date = params[:Transaction_date]
    @income_voucher.income_date = params[:Transaction_date]
    @expense.expense_date = params[:Transaction_date]
    @account_id = params[:Account]
    @account_name = @company.accounts.find(@account_id.to_i).name
    date = params[:Transaction_date]
    @transaction_type = params[:Transaction_type]
    @transaction_id = params[:Transaction_id]
    @transactions =  Ledger.find_matching_transactions(@company.id,@account_id,@amount)
  end

  def select_transaction
    @bank_statement_line_item = BankStatementLineItem.find(params[:id])
    if !params[:trans_id].blank?
      @transaction = Ledger.find(params[:trans_id])
      @transaction.update_attributes(:reconcilation_status => true, :reconcilation_date => Time.zone.now.to_date)
      @bank_statement_line_item.update_attributes(:status => 1, :ledger_id => @transaction.id)
    else
      flash.now[:error] = 'Select Transaction'
    end
  end

  #method for partial.js(ajax)
  def payment_mode
  end

  def create_receipt
  end

  def create_payment
  end

  def create_other_income
  end

  def create_expense
  end

  def report
    @accounts = Account.where(:company_id => @company.id, :accountable_type => 'BankAccount')
    @account_id = params[:account_id].blank? ? @accounts.first.id : params[:account_id]
    account = @company.accounts.find(@account_id)
    @start_date = Ledger.where(:account_id => @account_id).minimum(:transaction_date)
    @end_date = params[:as_on_date].blank? ? Time.zone.now.to_date : params[:as_on_date].to_date
    @account_balance = account.get_closing_balance(@current_user,@company.id, @financial_year,@end_date.to_date, @current_user.branch_id)
    if !@start_date.blank?
    statement_transactions = BankStatementLineItem.where("company_id =? and account_id =? and date BETWEEN ? AND ?",@company.id,@account_id,@start_date.to_date,@end_date.to_date)
      if !statement_transactions.blank?
        @statement_balance = statement_transactions.last.account_balance
      end
    @unreconciled_transactions = Ledger.where("account_id =? and reconcilation_status =? and transaction_date BETWEEN ? AND ?",@account_id,0,@start_date.to_date,@end_date.to_date).order("transaction_date DESC")
    end
  end

end

