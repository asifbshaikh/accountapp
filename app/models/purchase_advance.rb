class PurchaseAdvance < ActiveRecord::Base
#	  scope :not_in, lambda { |advance_payments| where("id not in(?)", advance_payments.map { |e| e.id }) unless advance_payments.blank?}
	scope :by_deleted, lambda {|del| where(:deleted => del)}
  	scope :by_date, lambda{|fin_year| where(:payment_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  	scope :by_account, lambda{|account| where(:to_account_id=> account) unless account.blank? }
  	scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
	scope :by_voucher_type, lambda { |voucher_type| where(:voucher_type=>voucher_type) unless voucher_type.blank? }

	has_many :ledgers, :as => :voucher, :dependent => :destroy
  	belongs_to :company
	has_many :gstr_advance_purchases_payments
	has_many :gstr_advance_payments, :through=>:gstr_advance_purchases_payments, :dependent=>:destroy

	belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  	belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  	has_one :payment_detail, :as => :voucher, :dependent => :destroy

  	accepts_nested_attributes_for :payment_detail
	accepts_nested_attributes_for :gstr_advance_purchases_payments, :reject_if=>lambda { |o| o[:amount].blank? }

	attr_accessible :voucher_type,:voucher_number, :voucher_date,:amount, :payment_detail_attributes,:to_account_id, :from_account_id,:gstr_advance_purchases_payments_attributes

	validates_presence_of  :voucher_number, :voucher_date,:amount, :to_account_id, :from_account_id
	validates_uniqueness_of :voucher_number, :scope=>:company_id
  	validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
    	:message => " should not be zero or negative ." }

    validate :validate_from_account_and_to_account
    validate :validate_from_account_type, :if => :from_account_id
  	validate :validate_to_account_type, :if => :to_account_id


 	def validate_from_account_and_to_account
	  if self.from_account_id == self.to_account_id
	    errors.add(:base, "Both accounts should not be same")
	  end
 	end

 	def validate_from_account_type
    	if !from_account.blank? && !(["BankAccount", "CashAccount","SecuredLoanAccount","UnsecuredLoanAccount","OtherCurrentAsset","CurrentLiability"]).include?(from_account.accountable_type)
	      errors.add(:from_account_id,"you entered is wrong, please select right account")
    	end
  	end

  	def validate_to_account_type
    	if !(["DirectExpenseAccount","IndirectExpenseAccount","LoansAdvancesAccount","LoanAccount","ProvisionAccount","SecuredLoanAccount",
      	"SundryCreditor", "SundryDebtor","UnsecuredLoanAccount","DepositAccount","SuspenseAccount", "CapitalAccount","DutiesAndTaxesAccounts"]).include?(Account.find(to_account_id).accountable_type)
      		errors.add(:to_account_id,"you entered is wrong, please select right account")
    	end
  	end


  	def save_and_manage_status(remote_ip)
	  transaction do
	    save_with_ledgers
	    gstr_advance_payments.each do |gstr_advance_payment|
	      gstr_advance_payment.update_gstr_advance_payment_status
	    end
	    # expenses.each do |expense|
	    #   expense.update_payment_status
	    # end
	    register_user_action(remote_ip, 'created')
	  end
	end
	
	def save_with_ledgers
			  save_result = false
			  transaction do
			    if save!
			      if tds_account_id.blank?

			        random_str=Ledger.generate_secure_random
			        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
			          ledger_amt, voucher_number, created_by, description, branch_id, random_str, from_account_id)

			        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, payment_date,
			          ledger_amt, voucher_number, created_by, description, branch_id, random_str, to_account_id)

			          #build and save relationship between receipt_voucher and ledgers
			          ledgers << debit_ledger_entry
			          ledgers << credit_ledger_entry
			      else
			        random_str1=Ledger.generate_secure_random
			        random_str2=Ledger.generate_secure_random
			        debit_ledger_entry1 = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
			          amount_after_tds, voucher_number, created_by, description, branch_id, random_str1, from_account_id)

			        credit_ledger_entry1 = Ledger.new_credit_ledger(from_account_id, company_id, payment_date,
			          amount_after_tds, voucher_number, created_by, description, branch_id, random_str1, to_account_id)

			        debit_ledger_entry2 = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
			          ledger_tds_amt, voucher_number, created_by, description, branch_id, random_str2, tds_account_id)

			        credit_ledger_entry2 = Ledger.new_credit_ledger(tds_account_id, company_id, payment_date,
			          ledger_tds_amt, voucher_number, created_by, description, branch_id, random_str2, to_account_id)

			        #build and save relationship between receipt_voucher and ledgers
			        ledgers << debit_ledger_entry1
			        ledgers << credit_ledger_entry1

			        ledgers << debit_ledger_entry2
			        ledgers << credit_ledger_entry2
			      end
			      self.gain_and_loss_ledger_entry
			      save_result = true
			      Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
			    end
			  end
			  save_result
		end


 	class << self

 		def new_payment(params, company)
		    purchase_advance = PurchaseAdvance.new
		    purchase_advance.company_id = company.id
		    purchase_advance.to_account_id = params[:account_id] unless params[:account_id].blank?
		    purchase_advance.voucher_date = Time.zone.now.to_date
		    #purchase_advance.payment_date = Time.zone.now.to_date
		    if params[:gstr_advance_payment_id].present?
		      purchase_advance.gstr_advance_payment_id = GstrAdvancePayment.find(params[:gstr_advance_payment_id])
		      purchase_advance.payment_id = purchase.id
		      purchase_advance.to_account_id = purchase.to_account_id
		      purchase_advance.amount = purchase.outstanding
		    # elsif params[:expense_id].present?
		    #   expense=Expense.find_by_id(params[:expense_id])
		    #   #purchase_advance.expense_id=expense.id
		    #   purchase_advance.to_account_id=expense.account_id
		    #   purchase_advance.amount=expense.outstanding
		    #   purchase_advance.currency_id=expense.currency_id
		    #   purchase_advance.exchange_rate=expense.exchange_rate
		    end
		    purchase_advance.build_payment_detail
		    purchase_advance.voucher_number = GstrAdvancePayment.find(params[:voucher_number])
		    #purchase_advance.old_file_size = 0
		    purchase_advance
  		end

  		def create_payment(params, company, user, fyr)
		    purchase_advance = PurchaseAdvance.new(params[:purchase_advance])
		    purchase_advance.company_id = company
		    #purchase_advance.created_by = user.id
		    #purchase_advance.old_file_size = 0
		    #purchase_advance.tds_applicable=params[:tds]
		    purchase_advance.from_account_id=nil if purchase_advance.from_account_id=="create_new"
		    purchase_advance.to_account_id=nil if purchase_advance.to_account_id=="create_new"
		    # purchase_advance.voucher_type=PAYMENT_OPTION[params[:payment_option]]
		    #purchase_advance.branch_id = user.branch_id unless user.branch_id.blank?
		    purchase_advance.currency_id = purchase_advance.to_account.get_currency_id unless purchase_advance.to_account.blank?
		    if purchase_advance.currency_id.blank? || purchase_advance.to_account.get_currency == purchase_advance.company.currency_code
		      purchase_advance.exchange_rate = 0
		    end
		    # if purchase_advance.against_vouchers?
		    #   purchase_advance.amount=0
		    #   purchase_advance.tds_amount=0
		    #   purchase_advance.purchases_payments.each do |purchase_payment|
		    #     purchase_advance.amount +=purchase_payment.amount
		    #     #purchase_advance.tds_amount += purchase_payment.tds_amount unless purchase_payment.tds_amount.blank?
		    #   end
		    #   # purchase_advance.expenses_payments.each do |expense_payment|
		    #   #   purchase_advance.amount +=expense_payment.amount
		    #   #   purchase_advance.tds_amount += expense_payment.tds_amount unless expense_payment.tds_amount.blank?
		    #   # end
		    # end
		    purchase_advance.payment_detail = fetch_payment_details(params)
		    purchase_advance.payment_detail.amount = purchase_advance.amount
		    purchase_advance
		end

		

		def fetch_payment_details(params)
		    if params[:transaction_type] == 'cheque'
		      payment = ChequePayment.new(params[:cheque_payment])
		    elsif params[:transaction_type] == 'card'
		      payment = CardPayment.new(params[:card_payment])
		    elsif params[:transaction_type] == 'ibank'
		      payment = InternetBankingPayment.new(params[:internet_banking_payment])
		    else
		      payment = CashPayment.new(params[:cash_payment])
		      payment.payment_date = Time.zone.now.to_date
		      payment
		    end
  		end

  	end
 	

end