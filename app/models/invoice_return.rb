# ProfitBooks
# Copyright (C) 2011-2015 by Profitbooks Solutions Pvt Ltd.
#
# This program is licensed to Profitbooks Solutions Pvt Ltd.
# This code cannot be copied, recproduced in anyway except with prior written
# permission of Profitbooks Solutions Pvt Ltd.
#------------------------------------------------------------------------------

# == Schema Information
# Schema version: 01
#
# Table name: invoice_returns
#
#+-----------------------+---------------+------+-----+---------+----------------+
#| Field                 | Type          | Null | Key | Default | Extra          |
#+-----------------------+---------------+------+-----+---------+----------------+
#| id                    | int(11)       | NO   | PRI | NULL    | auto_increment |
#| company_id            | int(11)       | NO   |     | NULL    |                |
#| invoice_id            | int(11)       | NO   |     | NULL    |                |
#| created_by            | int(11)       | NO   |     | NULL    |                |
#| invoice_return_number | varchar(255)  | YES  |     | NULL    |                |
#| account_id            | int(11)       | NO   |     | NULL    |                |
#| record_date           | date          | YES  |     | NULL    |                |
#| description           | text          | YES  |     | NULL    |                |
#| total_amount          | decimal(18,2) | YES  |     | 0.00    |                |
#| currency_id           | int(11)       | YES  |     | NULL    |                |
#| exchange_rate         | decimal(18,5) | YES  |     | 0.00000 |                |
#| credit_note_id        | int(11)       | YES  |     | NULL    |                |
#| warehouse_id          | int(11)       | YES  |     | NULL    |                |
#| created_at            | datetime      | YES  |     | NULL    |                |
#| updated_at            | datetime      | YES  |     | NULL    |                |
#| branch_id             | int(11)       | YES  |     | NULL    |                |
#+-----------------------+---------------+------+-----+---------+----------------+
#

class InvoiceReturn < ActiveRecord::Base
	include InvoiceBase
	include VoucherBase
	belongs_to :company
	belongs_to :account
	belongs_to :invoice
	has_many :invoice_return_line_items, :conditions=>{:line_type=>"InvoiceReturnLineItem"}, :dependent=>:destroy
	has_many :tax_line_items, :class_name=>"InvoiceReturnLineItem", :conditions=>{:line_type=>nil}, :dependent=>:destroy, :autosave=>true
	belongs_to :user, :foreign_key=>:created_by
	has_many :ledgers, :as => :voucher, :dependent => :destroy
	has_one :credit_note, :dependent=>:destroy
	has_one :gst_credit_note, :dependent=>:destroy
	validates_presence_of :record_date
	validates_presence_of :invoice_id
	validates_presence_of :invoice_return_number
	validates_presence_of :invoice_return_line_items
	validates_uniqueness_of :invoice_return_number, :scope=>:company_id
	validates_associated :invoice_return_line_items
	validate :record_date_should_not_less_than_invoice
	validate :financial_year_of_invoice
	validate :exchange_rate_present

	accepts_nested_attributes_for :invoice_return_line_items
	attr_accessible :warehouse_id, :company_id, :record_date, :invoice_id, :created_by, :invoice_return_number, :account_id,
	:description, :total_amount, :currency_id, :exchange_rate, :credit_note_id, :invoice_return_line_items_attributes

	#[FIXME] Determine if this is required
	#after_destroy :manage_payment_status

	ALLOCATION_STATUS={true=>"allocated", false=>"non_allocated"}
	def voucher_setting
	  VoucherSetting.by_voucher_type(22, company_id).first
	end

	#[FIXME] Determine if this is required
	def manage_payment_status
		invoice.update_invoice_status
	end

	def customer
		account.customer.blank? ? account.vendor : account.customer
	end

	def rollback_stock_if_retain
		invoice_return_line_items.each do |line_item|
			old_return_line=InvoiceReturnLineItem.find_by_id(line_item.id)
			unless old_return_line.blank?
				Stock.reduce(company_id, old_return_line.product_id, old_return_line.invoice_return.warehouse_id, old_return_line.quantity) if old_return_line.product.inventory?
			end
		end
	end

	def discount
    discount = 0
    invoice_return_line_items.each do |line|
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

	def is_credit_note_allocated?
		!credit_note.blank? && !credit_note.invoice_credit_allocations.blank?
	end

	def is_gst_credit_note_allocated?
		!gst_credit_note.blank? && !gst_credit_note.gst_credit_allocations.blank?
	end

	def allocation_enable?
		!in_frozen_year? && !credit_note.blank?
	end

	def in_frozen_year?
	  FinancialYear.check_if_frozen(company_id, record_date)
	end

	def save_and_manage_credit_note(remote_ip)
		result=false
		transaction do
			if save_with_ledgers
				retain_stock
				invoice_outstanding=invoice.return_substracted_outstanding
				if invoice_outstanding < 0
					reload
					invoice_outstanding*=-1
					credit_note_amount=[invoice_outstanding, total_amount].min
					if !invoice.gst_invoice?
						CreditNote.add_invoice_return_note(self, remote_ip, credit_note_amount) if credit_note_amount>0
					end
				end
				invoice.mark_return_status
				result=true
			end
		end
		result
	end

	def update_and_manage_credit_note(remote_ip)
		result=false
		transaction do
			rollback_stock_if_retain
			if update_and_post_ledgers
				retain_stock
				invoice_outstanding=invoice.return_substracted_outstanding
				if invoice_outstanding < 0
					reload
					invoice_outstanding*=-1
					credit_note_amount=[invoice_outstanding, total_amount].min
					if !invoice.gst_invoice?
						if credit_note.blank?
							CreditNote.add_invoice_return_note(self, remote_ip, credit_note_amount)
						else
							credit_note.update_attribute("amount", credit_note_amount)
						end
					end
				else
					 credit_note.destroy unless credit_note.blank?
				end
				invoice.mark_return_status
				result=true
			end
		end
		result
	end

	def save_with_ledgers
		invoice_status = invoice.invoice_status_id
		result=false
		transaction do
			if save
				if invoice_status == 0
					invoice_return_line_items.each do |line_item|
						random_str=Ledger.generate_secure_random
						credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, record_date, line_item.converted_amount, invoice_return_number, created_by, description, line_item.invoice_return.invoice.branch_id, random_str, line_item.product.income_account_id)
						debit_ledger_entry = Ledger.new_debit_ledger(line_item.product.income_account_id, company_id, record_date, line_item.converted_amount, invoice_return_number, created_by, description, line_item.invoice_return.invoice.branch_id, random_str, account_id)
						#build relationship between invoice and ledgers
						ledgers << credit_ledger_entry
						ledgers << debit_ledger_entry
					end

					tax_line_items.each do |line_item|
						tax_account = line_item.account
						next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
						random_str=Ledger.generate_secure_random
						credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, record_date, line_item.converted_amount, invoice_return_number, created_by, description, line_item.invoice_return.invoice.branch_id, random_str, line_item.account_id)
						debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, record_date, line_item.converted_amount, invoice_return_number, created_by, description, line_item.invoice_return.invoice.branch_id, random_str, account_id)
					  #build relationship between expense and ledgers
					  ledgers << credit_ledger_entry
					  ledgers << debit_ledger_entry
					end
				end
				result=true
			end
		end
		result
	end

	def update_and_post_ledgers
		result=false
		transaction do
			if save
				if gst_credit_note.blank?
					Ledger.delete(ledgers)
					invoice_return_line_items.reload
					invoice_return_line_items.each do |line_item|
						random_str=Ledger.generate_secure_random
						credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, record_date, line_item.converted_amount, invoice_return_number, created_by, description, line_item.invoice_return.invoice.branch_id, random_str, line_item.product.income_account_id)
						debit_ledger_entry = Ledger.new_debit_ledger(line_item.product.income_account_id, company_id, record_date, line_item.converted_amount, invoice_return_number, created_by, description, line_item.invoice_return.invoice.branch_id, random_str, account_id)
					#build relationship between invoice and ledgers
					ledgers << credit_ledger_entry
					ledgers << debit_ledger_entry
					end
					tax_line_items.reload
					tax_line_items.each do |line_item|
						tax_account = line_item.account
						next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
						random_str=Ledger.generate_secure_random
						credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, record_date, line_item.converted_amount, invoice_return_number, created_by, description, line_item.invoice_return.invoice.branch_id, random_str, line_item.account_id)
						debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, record_date, line_item.converted_amount, invoice_return_number, created_by, description, line_item.invoice_return.invoice.branch_id, random_str, account_id)
					  	#build relationship between expense and ledgers
					  	ledgers << credit_ledger_entry
					  	ledgers << debit_ledger_entry
					end
				end
				result=true
			end
		end
		result
	end

	def retain_stock
		invoice_return_line_items.each do |line_item|
			Stock.increase(company_id, line_item.product_id, warehouse_id, line_item.quantity, nil) if line_item.product.inventory?
		end
	end

	def exchange_rate_present
		if exchange_rate.blank? || (invoice.foreign_currency? && exchange_rate<=0)
			errors.add(:exchange_rate, "must be present")
		end
	end

	def financial_year_of_invoice
		if invoice.in_frozen_year?
			errors.add(:invoice, "can't be from frozen financial year")
		end
	end

	def record_date_should_not_less_than_invoice
		unless record_date.blank?
			if record_date<invoice.invoice_date
				errors.add(:record_date, "can't be less than invoice date")
			end
		end
	end

	def get_total_amount
		amount=0
		invoice_return_line_items.each do |line_item|
			amount+=line_item.amount
		end
		tax_line_items.each do |line_item|
			tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
			amount+=line_item.amount unless line_item.marked_for_destruction?
		end
		amount
	end

	# def build_tax
	#   invoice_return_line_items.each do |line|
	#   	unless line.marked_for_destruction?
 #  			line.invoice_return_taxes.each do |tax|
	# 	    account = tax.account
	# 		    unless account.blank? || line.quantity.blank? || line.unit_rate.blank?
	# 		      parent_tax_amount=0
	# 		      account.parent_child_accounts.reverse.each do |acc|
	# 		        if acc.parent_id.blank?
	# 		          tax_amount = acc.get_tax_amount(line.amount)
	# 		          parent_tax_amount = tax_amount
	# 		        else
	# 		          tax_amount = acc.get_tax_amount(parent_tax_amount)
	# 		        end
	# 		        tax_line_items << InvoiceReturnLineItem.new(:account_id => acc.id, :tax => 1, :amount => tax_amount)
	# 		      end
	# 		    end
	# 		  end
	# 	  end
	#   end
	# end

	class << self
		def new_invoice_return(params, company)
			invoice_return=InvoiceReturn.new
			invoice_return.invoice_return_number=VoucherSetting.next_invoice_return_number(company)
			invoice_return.company_id=company.id
			invoice_return.record_date=Time.zone.now.to_date
			invoice=company.invoices.find_by_id(params[:invoice_id])
			unless invoice.blank?
				invoice_return.invoice_id=invoice.id
				invoice_return.account_id=invoice.account_id
				invoice_return.currency_id=invoice.currency_id
				invoice_return.exchange_rate=invoice.exchange_rate
				invoice.invoice_line_items.each do |line_item|
					unless line_item.fully_returned?
						return_line_item=return_line_item(line_item)
						line_item.invoice_taxes.each do |tax|
							return_line_item.invoice_return_taxes<<InvoiceReturnTax.new(:account_id=>tax.account_id)
						end
						invoice_return.invoice_return_line_items<<return_line_item
					end
				end
			end
			invoice_return
		end

		def return_line_item(invoice_line_item)
			return_line=InvoiceReturnLineItem.new
			return_line.account_id=invoice_line_item.account_id
			return_line.quantity=invoice_line_item.ready_to_return_quantity
			return_line.unit_rate=invoice_line_item.item_cost
			return_line.tax=invoice_line_item.tax
			return_line.line_type=invoice_line_item.type
			return_line.product_id=invoice_line_item.product_id
			return_line.tax_account_id=invoice_line_item.tax_account_id
			return_line.discount_percent=invoice_line_item.discount_percent
			return_line.invoice_line_item_id=invoice_line_item.id
			return_line
		end

		# This method takes the invoice return parameters, company and user creating
		# the return
		def create_invoice_return(params, company, user)
			invoice_return=InvoiceReturn.new(params[:invoice_return])
			invoice=company.invoices.find(invoice_return.invoice_id)
			invoice_return.created_by=user
			invoice_return.company_id=company.id
			invoice_return.account_id=invoice.account_id
			invoice_return.currency_id=invoice.currency_id
			invoice_return.branch_id=invoice.branch_id
			if invoice.blank?
				invoice_return.invoice_id=nil
			end
			invoice_return.invoice_return_line_items.each do |line_item|
				amount=0.0
				amount=line_item.quantity*line_item.unit_rate unless line_item.quantity.blank? || line_item.unit_rate.blank?
				if amount>0 && !line_item.discount_percent.blank? && line_item.discount_percent>0.0
					discount=(line_item.discount_percent/100.0)
					amount=amount-(amount*discount)
				end
				line_item.amount=amount
			end
			invoice_return.build_tax
			invoice_return.total_amount=invoice_return.get_total_amount
			invoice_return
		end

		def update_invoice_return(params, company)
			invoice_return=InvoiceReturn.find(params[:id])
			# InvoiceReturnLineItem.delete(invoice_return.tax_line_items)
			invoice_return.tax_line_items.each do |line_item|
				line_item.mark_for_destruction
			end
			# invoice_return.reload
			invoice_return.assign_attributes(params[:invoice_return])
			invoice_return.invoice_return_line_items.each do |line_item|
				amount=0.0
				amount=line_item.quantity*line_item.unit_rate unless line_item.quantity.blank? || line_item.unit_rate.blank?
				if amount>0 && !line_item.discount_percent.blank? && line_item.discount_percent>0.0
					discount=(line_item.discount_percent/100.0)
					amount=amount-(amount*discount)
				end
				line_item.amount=amount
			end
			invoice_return.build_tax
			invoice_return.total_amount=invoice_return.get_total_amount
			invoice_return
		end
	end
end
