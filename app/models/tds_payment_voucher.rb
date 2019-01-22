class TdsPaymentVoucher < ActiveRecord::Base
 scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
 scope :by_date, lambda{|fin_year| where(:payment_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}

  has_many :ledgers, :as => :voucher, :dependent => :destroy
  belongs_to :company

  has_one :payment_detail, :as => :voucher, :dependent => :destroy

  accepts_nested_attributes_for :payment_detail
  attr_accessible :description, :challan_no, :payment_date, :tan_no, :assessment_year, :tds_account_id, :account_id, :basic_tax,
                   :surcharge, :edu_cess, :other, :penalty, :interest, :cin_no, :bsr_code
   #validations
  validates_presence_of  :payment_date, :tds_account_id, :account_id, :assessment_year, :tan_no, :cin_no, :bsr_code, :challan_no

  # validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        # :message => " should not be zero or negative ." }
  # method to calculate amount
  def amount
    amt = 0
    amt += basic_tax+surcharge+edu_cess+other+penalty+interest
    amt
  end

  class << self
    def new_tds_payment(params)
      tds_payment_voucher = TdsPaymentVoucher.new
      # tds_payment_voucher.tds_account_id = params[:tds_account_id] unless params[:tds_account_id].blank?
      tds_payment_voucher.build_payment_detail
      tds_payment_voucher
    end

    def create_tds_payment(params, company, user, fyr)
      tds_payment_voucher = TdsPaymentVoucher.new(params[:tds_payment_voucher])
      tds_payment_voucher.company_id = company
      tds_payment_voucher.created_by = user.id
      # tds_payment_voucher.fin_year = fyr
      tds_payment_voucher.tds_account_id = Account.get_account_id(params[:tds_account_id], company)
      tds_payment_voucher.account_id = Account.get_account_id(params[:account_id], company)
      tds_payment_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      tds_payment_voucher.payment_detail = fetch_payment_details(params)
      tds_payment_voucher.payment_detail.amount = tds_payment_voucher.amount
      tds_payment_voucher
    end

    def update_tds_payment(params, company, user, fyr)
      tds_payment_voucher = TdsPaymentVoucher.find(params[:id])
      tds_payment_voucher.tds_account_id = Account.get_account_id(params[:tds_account_id], company)
      tds_payment_voucher.account_id = Account.get_account_id(params[:account_id], company)
      tds_payment_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      tds_payment_voucher.payment_detail.amount = tds_payment_voucher.amount
      # tds_payment_voucher.fin_year = fyr
      tds_payment_voucher
    end

    def fetch_payment_details(params)
      if params[:transaction_type] == 'cheque'
        payment = ChequePayment.new(params[:cheque_payment])
      elsif params[:transaction_type] == 'ibank'
        payment = InternetBankingPayment.new(params[:internet_banking_payment])
      else
        payment = CashPayment.new(params[:cash_payment])
        payment.payment_date = Time.zone.now.to_date
        payment
      end
    end
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " TDS Payment #{action} for #{challan_no} for amount #{amount} ", action, branch_id)
  end

def get_product(tax_id)

  end


#method for saving payment voucher with ledger
def save_with_ledgers
    save_result = false
    transaction do
      if save
          debit_ledger_entry = Ledger.new_debit_ledger(tds_account_id, company_id, payment_date,
            amount, challan_no, created_by, description, branch_id, account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, payment_date,
            amount, challan_no, created_by, description, branch_id, tds_account_id)

          #build and save relationship between receipt_voucher and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry

        save_result = true
      end
    end
    save_result
  end

#method for updating payment voucher with ledger
  def update_and_post_ledgers
    update_result = false
    transaction do
     if update
     Ledger.delete(ledgers)

          debit_ledger_entry = Ledger.new_debit_ledger(tds_account_id, company_id, payment_date,
            amount, challan_no, created_by, description, branch_id, account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, payment_date,
            amount, challan_no, created_by, description, branch_id, tds_account_id)

          #build and save relationship between receipt_voucher and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
       update_result = true
    end
   end
      update_result
  end

end
