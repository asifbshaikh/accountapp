class PurchaseReturn < ActiveRecord::Base
	include VoucherBase
	scope :not_in, lambda { |purchase_returns| where("id not in(?)", purchase_returns.map { |e| e.id }) unless purchase_returns.blank?}
	belongs_to :company
	belongs_to :purchase
	belongs_to :account
	has_many :purchase_return_line_items, :conditions => {:line_type => "PurchaseReturnLineItem"}, :dependent=>:destroy
	has_many :tax_line_items, :class_name => "PurchaseReturnLineItem", :conditions => {:line_type => nil}, :dependent => :destroy, :autosave=>true
	has_one :debit_note, :dependent=>:destroy
	has_one :gst_debit_note, :dependent=>:destroy
	belongs_to :user, :foreign_key=>:created_by
	has_many :ledgers, :as => :voucher, :dependent => :destroy

	validates_presence_of :record_date
	validates_presence_of :purchase_id, :message=>"Invalid purchase reference"
	validates_presence_of :purchase_return_number
	validates_presence_of :warehouse_id
	validates_presence_of :purchase_return_line_items
	validates_uniqueness_of :purchase_return_number, :scope=>:company_id

	validate :record_date_should_not_less_than_purchase
	validate :exchange_rate_present

	accepts_nested_attributes_for :purchase_return_line_items
	attr_accessible :warehouse_id, :company_id, :record_date, :purchase_id, :created_by, :purchase_return_number, :account_id,
	:customer_notes, :total_amount, :currency_id, :exchange_rate, :debit_note_id, :purchase_return_line_items_attributes

	validates_associated :purchase_return_line_items
	validate :financial_year_of_purchase
	validate :available_inventory
	after_destroy :manage_payment_status
	validate :account_effective_date

	ALLOCATION_STATUS={true=>"allocated", false=>"non_allocated"}
	def voucher_setting
	  VoucherSetting.by_voucher_type(21, company_id).first
	end

	def account_effective_date
		if !account.blank? && !record_date.blank? && record_date < account.start_date
		  errors.add(:record_date, "must be after account activation, #{account.name} is activated since #{account.start_date}")
		end
	end
	def get_product(tax_id)
	  caccount = Account.find_by_id(tax_id)
	  paccount = Account.find_by_id(caccount.parent_id)
	  line = purchase_return_line_items.includes(:purchase_return_taxes).where(:purchase_return_taxes=>{:account_id => paccount.blank? ? caccount.id : paccount.id}).first
	  line.product
	end

	def is_debit_note_allocated?
		!debit_note.blank? && !debit_note.purchase_debit_allocations.blank?
	end
	def allocation_enable?
		!in_frozen_year? && !debit_note.blank?
	end
	def manage_payment_status
		purchase.reload
		if purchase.outstanding>0
			purchase.update_attribute("status_id", 0)
		else
			purchase.update_attribute("status_id", 1)
		end
	end

	def financial_year_of_purchase
		if purchase.in_frozen_year?
			errors.add(:purchase, "can't be from frozen financial year")
		end
	end

	def save_and_update_total_amount(remote_ip)
		result=false
		transaction do
			if save_with_ledgers
				retain_stock
				purchase_outstanding=purchase.return_substracted_outstanding
				if purchase_outstanding < 0
					reload
					purchase_outstanding*=-1
					debit_note_amount=[purchase_outstanding, total_amount].min
					#DebitNote.add_purchase_return_note(self, remote_ip, debit_note_amount) if debit_note_amount>0
				end
				manage_payment_status
				result=true
			end
		end
		result
	end

	def update_and_create_debit_note(remote_ip)
		result=false
		transaction do
			rollback_stock_if_retain
			if update_and_post_ledgers
				retain_stock
				purchase_outstanding=purchase.return_substracted_outstanding
				if purchase_outstanding < 0
					reload
					purchase_outstanding*=-1
					debit_note_amount=[purchase_outstanding, total_amount].min
					# if debit_note.blank?
					# 	DebitNote.add_purchase_return_note(self, remote_ip, debit_note_amount)
					# else
					# 	debit_note.update_attribute("amount", debit_note_amount)
					# end
				else
					 debit_note.destroy unless debit_note.blank?
				end
				manage_payment_status
				result=true
			end
		end
		result
	end

	def save_with_ledgers
		# result=false
		# transaction do
		# 	if save
		# 		purchase_return_line_items.each do |line_item|
		# 			random_str=Ledger.generate_secure_random
		# 			credit_ledger_entry = Ledger.new_credit_ledger(line_item.product.expense_account_id, company_id, record_date, line_item.converted_amount, purchase_return_number, created_by, customer_notes, line_item.purchase_return.purchase.branch_id, random_str, account_id)
		# 			debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, record_date, line_item.converted_amount, purchase_return_number, created_by, customer_notes, line_item.purchase_return.purchase.branch_id, random_str, line_item.product.expense_account_id)
		# 			#build relationship between invoice and ledgers
		# 			ledgers << credit_ledger_entry
		# 			ledgers << debit_ledger_entry
		# 		end

		# 		tax_line_items.each do |line_item|
		# 			 tax_account = line_item.account
  #      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
		# 		  random_str=Ledger.generate_secure_random
		# 		  credit_ledger_entry = Ledger.new_credit_ledger(line_item.account_id, company_id, record_date, line_item.converted_amount, purchase_return_number, created_by, customer_notes, line_item.purchase_return.purchase.branch_id, random_str, account_id)
		# 		  debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, record_date, line_item.converted_amount, purchase_return_number, created_by, customer_notes, line_item.purchase_return.purchase.branch_id, random_str, line_item.account_id)
		# 		  #build relationship between expense and ledgers
		# 		  ledgers << credit_ledger_entry
		# 		  ledgers << debit_ledger_entry
		# 		end
		# 		result=true
		# 	end
		# end
		# result

		result=false
		transaction do
			if save
				result=true
			end
		end
		result
	end

	def update_and_post_ledgers
		# result=false
		# transaction do
		# 	if save
		# 		Ledger.delete(ledgers)
		# 		purchase_return_line_items.reload
		# 		purchase_return_line_items.each do |line_item|
		# 			random_str=Ledger.generate_secure_random
		# 			credit_ledger_entry = Ledger.new_credit_ledger(line_item.product.expense_account_id, company_id, record_date, line_item.amount, purchase_return_number, created_by, customer_notes, line_item.purchase_return.purchase.branch_id, random_str, account_id)
		# 			debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, record_date, line_item.amount, purchase_return_number, created_by, customer_notes, line_item.purchase_return.purchase.branch_id, random_str, line_item.product.expense_account_id)
		# 			#build relationship between invoice and ledgers
		# 			ledgers << credit_ledger_entry
		# 			ledgers << debit_ledger_entry
		# 		end
		# 		tax_line_items.reload
		# 		tax_line_items.each do |line_item|
		# 			 tax_account = line_item.account
  #      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
		# 		  random_str=Ledger.generate_secure_random
		# 		  credit_ledger_entry = Ledger.new_credit_ledger(line_item.account_id, company_id, record_date, line_item.converted_amount, purchase_return_number, created_by, customer_notes, line_item.purchase_return.purchase.branch_id, random_str, account_id)
		# 		  debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, record_date, line_item.converted_amount, purchase_return_number, created_by, customer_notes, line_item.purchase_return.purchase.branch_id, random_str, line_item.account_id)
		# 		  #build relationship between expense and ledgers
		# 		  ledgers << credit_ledger_entry
		# 		  ledgers << debit_ledger_entry
		# 		end
		# 		result=true
		# 	end
		# end
		# result

		result=false
		transaction do
			if save
				result=true
			end
		end
		result
	end

	def available_inventory
	  product_stocks ={}
	  purchase_return_line_items.each do |line|
	  	if  line.product.inventory?
		  	old_line=PurchaseReturnLineItem.find_by_id(line.id)
	      stock = Stock.find_by_warehouse_id_and_product_id(warehouse_id, line.product_id)
	      unless stock.blank? || line.quantity.blank?
	        if product_stocks["#{stock.id}"].blank?
	          quantity=stock.quantity
	          quantity+= old_line.quantity unless old_line.blank?
	          if line.quantity > quantity
	            errors.add(:base, "low stock for #{line.product.name}")
	          else
	            product_stocks["#{stock.id}"] = (quantity - line.quantity) unless quantity.blank?
	          end
	        elsif product_stocks["#{stock.id}"].to_i < line.quantity
	          errors.add(:base, "low stock for #{line.product.name}")
	        else
	          product_stocks["#{stock.id}"] = product_stocks["#{stock.id}"].to_i - line.quantity
	        end
	      end
	      errors.add(:stock, "not available for #{line.product.name}") if stock.blank?
	    end
	  end
	end

	def rollback_stock_if_retain
		purchase_return_line_items.each do |line_item|
			old_return_line=PurchaseReturnLineItem.find_by_id(line_item.id)
			unless old_return_line.blank?
				Stock.increase(company_id, old_return_line.product_id, old_return_line.purchase_return.warehouse_id, old_return_line.quantity, nil) if old_return_line.product.inventory?
			end
		end
	end

	def retain_stock
		purchase_return_line_items.each do |line_item|
			Stock.reduce(company_id, line_item.product_id, warehouse_id, line_item.quantity) if line_item.product.inventory?
		end
	end

	def exchange_rate_present
		if exchange_rate.blank? || (purchase.foreign_currency? && exchange_rate<=0)
			errors.add(:exchange_rate, "must be present")
		end
	end

	def record_date_should_not_less_than_purchase
		unless record_date.blank?
			if record_date<purchase.record_date
				errors.add(:record_date, "can't be less than purchase date")
			end
		end
	end
	# Methods that used in purchase and purchase_return can move to common place
	def vendor
		account.vendor.blank? ? account.customer : account.vendor
	end
	def in_frozen_year?
	  FinancialYear.check_if_frozen(company_id, record_date)
	end
	def discount
    discount = 0
    purchase_return_line_items.each do |line|
      discount += (line.unit_rate*line.quantity)*(line.discount_percent/100.0) unless line.amount.blank? || line.discount_percent.blank?
    end
    discount
  end

	def group_tax_amt(account_id)
	  amt = 0
	  tax_items = self.tax_line_items.where(:account_id => account_id)
	  tax_items.each do |item|
	    amt += item.amount
	  end
	  amt
	end

	# def build_tax
	#   purchase_return_line_items.each do |line|
	#   	unless line.marked_for_destruction?  || line.quantity.blank? || line.unit_rate.blank?
	#   		line.purchase_return_taxes.each do |tax|
	# 		    account = tax.account
	# 		    unless account.blank?
	# 		      parent_tax_amount=0
	# 		      account.parent_child_accounts.reverse.each do |acc|
	# 		        if acc.parent_id.blank?
	# 		          tax_amount = acc.get_tax_amount(line.amount)
	# 		          parent_tax_amount = tax_amount
	# 		        else
	# 		          tax_amount = acc.get_tax_amount(parent_tax_amount)
	# 		        end
	# 		        tax_line_items << PurchaseReturnLineItem.new(:account_id => acc.id, :tax => 1, :amount => tax_amount)
	# 		      end
	# 		    end
	# 		  end
	# 	  end
	#   end
	# end

	def currency
    if foreign_currency?
      Currency.find(currency_id).currency_code
    else
      self.company.currency_code
    end
  end

  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate != 0
  end
	# End of common methods

	def get_total_amount
		amount=0
		purchase_return_line_items.each do |line_item|
			amount+=line_item.amount
		end
		tax_line_items.each do |line_item|
			tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
			amount+=line_item.amount unless line_item.marked_for_destruction?
		end
		amount
	end

	class << self
		def new_purchase_return(params, company)
			purchase_return=PurchaseReturn.new
			purchase_return.purchase_return_number=VoucherSetting.next_purchase_return_number(company)
			purchase_return.company_id=company.id
			purchase_return.record_date=Time.zone.now.to_date
			purchase=company.purchases.find_by_id(params[:purchase_id])
			unless purchase.blank?
				purchase_return.purchase_id=purchase.id
				purchase_return.account_id=purchase.account_id
				purchase_return.currency_id=purchase.currency_id
				purchase_return.exchange_rate=purchase.exchange_rate
				purchase.purchase_line_items.each do |line_item|
					unless line_item.fully_returned?
						return_line_item=return_line_item(line_item)
						line_item.purchase_taxes.each do |tax|
							return_line_item.purchase_return_taxes<<PurchaseReturnTax.new(:account_id=>tax.account_id)
						end
						purchase_return.purchase_return_line_items<<return_line_item
					end
				end
			end
			purchase_return
		end


		def return_line_item(purchase_line_item)
			return_line=PurchaseReturnLineItem.new
			return_line.account_id=purchase_line_item.account_id
			return_line.quantity=purchase_line_item.ready_to_return_quantity
			return_line.unit_rate=purchase_line_item.unit_rate
			return_line.tax=purchase_line_item.tax
			return_line.line_type=purchase_line_item.type
			return_line.product_id=purchase_line_item.product_id
			return_line.tax_account_id=purchase_line_item.tax_account_id
			return_line.discount_percent=purchase_line_item.discount_percent
			return_line.purchase_line_item_id=purchase_line_item.id
			return_line
		end

		def create_purchase_return(params, company, user)
			purchase_return=PurchaseReturn.new(params[:purchase_return])
			purchase=company.purchases.find(purchase_return.purchase_id)
			purchase_return.created_by=user
			purchase_return.company_id=company.id
			purchase_return.account_id=purchase.account_id
			purchase_return.currency_id=purchase.currency_id
			purchase_return.branch_id=purchase.branch_id
			if purchase.blank?
				purchase_return.purchase_id=nil
			end
			purchase_return.purchase_return_line_items.each do |line_item|
				amount=0.0
				amount=line_item.quantity*line_item.unit_rate unless line_item.quantity.blank? || line_item.unit_rate.blank?
				if amount>0 && !line_item.discount_percent.blank? && line_item.discount_percent>0.0
					discount=(line_item.discount_percent/100.0)
					amount=amount-(amount*discount)
				end
				line_item.amount=amount
			end
			purchase_return.build_tax
			purchase_return.total_amount=purchase_return.get_total_amount
			purchase_return
		end

		def update_purchase_return(params, company)
			purchase_return=PurchaseReturn.find(params[:id])
			# PurchaseReturnLineItem.delete(purchase_return.tax_line_items)
			# purchase_return.reload
			purchase_return.tax_line_items.each do |line_item|
				line_item.mark_for_destruction
			end
			purchase_return.assign_attributes(params[:purchase_return])
			purchase_return.purchase_return_line_items.each do |line_item|
				amount=0.0
				amount=line_item.quantity*line_item.unit_rate unless line_item.quantity.blank? || line_item.unit_rate.blank?
				if amount>0 && !line_item.discount_percent.blank? && line_item.discount_percent>0.0
					discount=(line_item.discount_percent/100.0)
					amount=amount-(amount*discount)
				end
				line_item.amount=amount
			end
			purchase_return.build_tax
			purchase_return.total_amount=purchase_return.get_total_amount
			purchase_return
		end
	end
end
