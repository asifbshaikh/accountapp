class ExpenseLineItem < ActiveRecord::Base
	include VoucherLineItem
	belongs_to :expense
	belongs_to :account
	has_many :expense_taxes, :dependent=>:destroy
	has_many :tax_accounts, :class_name=>"Account", :through=>:expense_taxes, :source=>:account

	#validations
	validates_presence_of :account_id, :amount
	validates :account_id, :numericality => {greater_than: 0,
		:message => "Invalid expense in line item"}
	validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
	                          :message => " should not be zero or negative ." }
	# validates :account_id, :uniqueness => { :scope => :expense_id, :message => "should once per expense entry"}

	accepts_nested_attributes_for :expense_taxes#, :reject_if=>lambda { |o| o[:account_id].blank? }
	attr_accessible :tax, :account_id, :description, :amount, :type, :created_at, :updated_at, :expense_id, :expense_taxes_attributes, :eligibility, :igst, :cgst, :sgst
	before_save :check_tax_destruction
	def check_tax_destruction
	  expense_taxes.each do |tax|
	    tax.mark_for_destruction if tax.account_id.blank?
	  end
	end
	def converted_amount
	  self.expense.foreign_currency? ? (amount*self.expense.exchange_rate).round(2) : amount
	end
  
  def gst_tax_rate
    self.tax_accounts.first.accountable.tax_rate
  end
	# def tax_amount
	# 	total_tax=0
	# 	tax_accounts.each do |account|
	# 		unless amount.blank?
	# 		  parent_tax_amount=0
	# 		  account.parent_child_accounts.reverse.each do |acc|
	# 		    if acc.parent_id.blank?
	# 		      tmp_amount = acc.get_tax_amount(amount)
	# 		      total_tax+=tmp_amount
	# 		      parent_tax_amount = tmp_amount
	# 		    else
	# 		      total_tax+=acc.get_tax_amount(parent_tax_amount)
	# 		    end
	# 		  end
	# 		end
	# 	end
	# 	total_tax
	# end

	def self.subclasses
		[TaxLineItem]
	end

	def delete_with_ledger
		expense = self.expense

		to_ledger_entry = expense.ledgers.find_by_account_id(account_id)
		from_ledger_entry = nil
		from_ledger_entry = expense.ledgers.find(:first, :conditions => "voucher_number='#{expense.voucher_number}' and account_id='#{expense.account_id}' and debit=#{to_ledger_entry.credit}") unless to_ledger_entry.blank?
		transaction do
			to_ledger_entry.destroy unless to_ledger_entry.blank?
			from_ledger_entry.destroy unless from_ledger_entry.blank?
			destroy
		end
	end
end
