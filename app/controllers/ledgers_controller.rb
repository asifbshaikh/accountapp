class LedgersController < ApplicationController

  layout "application"#, :except => [:show]
  # GET /ledgers
  # GET /ledgers.xml
  def index
    @menu = "Banking"
    @page_name = "Reconciliation"
    @accounts = @company.get_accounts_of('Bank Accounts')
    if  !@accounts.blank?
      if !params[:account_id].nil? && !(params[:account_id]).blank? && (params[:start_date].nil? || params[:start_date].blank?) && (params[:end_date].nil? || params[:end_date].blank?)
        @ledgers = Ledger.order(:transaction_date).find_all_by_account_id_and_bank_transaction_date(params[:account_id], nil)
      elsif !params[:account_id].nil? && !(params[:account_id]).blank? && !(params[:start_date].nil? || params[:start_date].blank?) && !(params[:end_date].nil? || params[:end_date].blank?)
        @ledgers = Ledger.where("account_id = ? and transaction_date between ? and ?", params[:account_id], params[:start_date], params[:end_date])
      elsif !params[:account_id].nil? && !(params[:account_id]).blank? && !(params[:start_date].nil? || params[:start_date].blank?)
        @ledgers = Ledger.where("account_id = ? and transaction_date between ? and ?", params[:account_id], params[:start_date], Time.zone.now.to_date).order(:transaction_date)
      elsif !params[:account_id].nil? && !(params[:account_id]).blank? && !(params[:end_date].nil? || params[:end_date].blank?)
        @ledgers = Ledger.where("account_id = ? and transaction_date <= ?", params[:account_id], params[:end_date]).order(:transaction_date)
      else
        @ledgers = Ledger.order(:transaction_date).find_all_by_account_id_and_bank_transaction_date(@accounts.first.id, nil)
      end
    end
     #Ledger.update_all(["bank_transaction_date =?", Time.zone.now], :id => params[:ledger_ids])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ledgers }
    end
  end

  
  def edit_multiple
    @ledgers = Ledger.find(params[:ledger_ids])
  end

  def update_multiple
    @ledgers = Ledger.find(params[:ledger_ids])
    @ledgers.each do |ledger|
      ledger.update_attributes(:bank_transaction_date => Time.zone.now)
    end
    flash[:notice] = "Updated ledgers!"
    redirect_to ledgers_path
  end
end
