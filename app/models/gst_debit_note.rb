class GstDebitNote < ActiveRecord::Base
  include VoucherBase
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:transaction_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("gst_debit_note_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_from_account, lambda{|from_account| where(:from_account_id=>from_account) unless from_account.blank? }
  scope :by_to_account, lambda{|to_account| where(:to_account_id=>to_account) unless to_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:transaction_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  scope :by_status, lambda{|status| where(:status_id => status) unless status.blank?}
  belongs_to :account
	belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
	belongs_to :company
	has_many :ledgers, :as => :voucher, :dependent => :destroy
	belongs_to :purchase_return
	has_many :gst_debit_allocations
  has_many :purchase
  has_many :gst_debit_note_line_items, :conditions => {:line_type => "GstDebitNoteLineItem"}, :dependent => :destroy
  has_many :tax_line_items, :class_name => "GstDebitNoteLineItem", :conditions => {:line_type => nil}, :dependent => :destroy

  accepts_nested_attributes_for :gst_debit_note_line_items, :reject_if => lambda {|a| a[:product_id].blank? && a[:amount].blank? || a[:amount]=='0.0' }, :allow_destroy => true
  accepts_nested_attributes_for :tax_line_items, :reject_if => lambda {|a| a[:from_account_id].blank? && a[:amount].blank? }, :allow_destroy => true
	accepts_nested_attributes_for :gst_debit_allocations, :reject_if => lambda {|a| a[:amount].blank? || a[:amount].to_f==0 }

  #attr_accessible :purchase_line_items_attributes, :tax_line_items_attributes, :status_id
	#validations
	validates :gst_debit_note_number ,:gst_debit_note_date,:amount,:created_by , :presence=> true
	#validates_presence_of :from_account_id, :if=>lambda { |a| !a.read_only? }
	validates_uniqueness_of :gst_debit_note_number, :scope=>:company_id
	# validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
	#        :message => " should not be zero or negative."}

	validate :amount_allocation
   # validate :save_only_in_current_year
  attr_accessor :fin_year


  STATUS = {'0' => 'Open', '1' => 'Allocated', '2' => 'Refund'}

	def voucher_setting
    VoucherSetting.by_voucher_type(28, company_id).first
  end

  def gst_line_items
    #create a hash with key as tax rate 
    #get the line item rate, check if the rate is present in hash
    #if not add a new gst_line_item_object to it
    #if present get the gst_line_item and add required fields to them
    items = Hash.new
    self.gst_debit_note_line_items.each do |line_item|
      rate = line_item.gst_tax_rate
      if items.has_key? rate
        gst_tax_item = items[rate]
        gst_tax_item.add_txn_value(line_item.amount)
        gst_tax_item.add_igst_amt(line_item.igst_amt)
        gst_tax_item.add_cgst_amt(line_item.cgst_amt)
        gst_tax_item.add_sgst_amt(line_item.sgst_amt)
      else
        items[rate] = GstPurchaseLineItem.new(rate, line_item.amount, line_item.igst_amt, line_item.cgst_amt, line_item.sgst_amt)
      end
    end
    items.values
  end

  def total_amount
    amount
  end
  def currency
    code=company.currency_code
    code=purchase_return.currency unless purchase_return.blank?
    code
  end

  def manage_purchase_and_gst_debit_note_status
    gst_debit_allocations.each do |allocation|
      allocation.purchase.update_purchase_status
    end
  end

  def manage_gst_debit_note_status
      if unallocated_amount == 0
        self.update_attribute("status_id", 1)
      # else
      #   self.update_attribute("status_id", 0)
      end
    
  end

  def amount_allocation
    if amount<allocated_amount
      errors.add(:amount, "can't be greater than unallocated amount")
    end
  end

  def allocated_amount
    amount=0
    gst_debit_allocations.each do |allocation|
      amount+=allocation.amount unless allocation.amount.blank?
    end
    amount
  end
 
  def unallocated_amount
    amount-gst_debit_allocations.sum(:amount)
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, gst_debit_note_date)
  end

  def discount
    discount = 0
    gst_debit_note_line_items.each do |line|
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

	def account
		Account.find(from_account_id) unless from_account_id.blank?
	end

	def customer
		customer=nil
    logger.debug "account #{account.inspect}"
		if account.customer.blank?
			customer=account.vendor
		else
			customer=account.customer
		end
    logger.debug "custo #{customer.inspect}"
		customer
	end

  def get_status
    logger.debug "status #{status_id.inspect}"
    if status_id == 1
      "Allocated"
    elsif status_id == 2
      "Refund"
    elsif status_id == 0
      "Open"
    end
  end

	def account_name
    Account.find(account_id).name
  end

  def to_account_name
    Account.find(from_account_id).name
  end

  def vendor_name
    Account.find(from_account_id).name
  end

  def voucher_date
    gst_debit_note_date
  end

  def sub_total
   self.gst_debit_note_line_items.sum(:amount)
  end

  def tax_total_amount
    tax_total=0  
        tax_line_items.each do |line_item|
           tax_account = line_item.account
           next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
          tax_total += line_item.amount unless line_item.amount.blank?
        end
    tax_total
  end

  def calculate_total_amount
    debit_total =0
    gst_debit_note_line_items.each do |line_item|
      debit_total += line_item.amount
    end

    tax_total=0
    tax_line_items.each do |line_item|
      tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
      tax_total += line_item.amount
    end

    total = debit_total + tax_total
  end

  def allocation_enable?
    !in_frozen_year? && opened?
  end

  def cgst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0 && !tax_account.name.include?("CGST"))
       if tax_account.name.include?("CGST")
            amt+= line_item.amount
       end
    end   
    amt
  end


  def sgst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       if tax_account.name.include?("SGST")
          amt+= line_item.amount
        end
    end   
    amt
  end

  def igst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       if tax_account.name.include?("IGST")
        amt+= line_item.amount
        end
    end   
    amt
  end

  def customer_name
      self.account.name  unless self.account.blank?  
  end

  def customer_GSTIN
    gstin = nil
    customer = self.from_account.customer
    if customer.present?
      gstin = customer.gstn_id
    end 
    gstin
  end

  def delete_gstr_two_entry
    @gstr_two_debit_note = GstrTwoItem.find_by_voucher_id_and_voucher_type(id,"GstDebitNote")
    @gstr_two_debit_note.destroy
  end


  def tax
    amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       amt+= line_item.amount
    end   
    amt
  end

  class << self

    def create_allocation(params, company)
      gst_debit_note=company.gst_debit_notes.find(params[:id])
      gst_debit_note.assign_attributes(params[:gst_debit_note])
      gst_debit_note
    end

    # def allocate_gst_debit(params, company)
    #   logger.debug "params #{params.inspect}"
    #   gst_debit_note = 
    #   allocated_purchases = gst_debit_note.gst_debit_allocations
    #   unallocated_purchases = company.purchases.not_in(allocated_purchases).by_vendor(gst_debit_note.created_by).by_status(0).by_currency(gst_debit_note.to_account.get_currency_id)
    #   unallocated_purchases.each do |purchase|
    #     gst_debit_allocation=GstDebitAllocation.new(:purchase_id=>purchase.id, :amount=>0)
    #     gst_debit_note.gst_debit_allocations<<gst_debit_allocation
    #   end
    #   gst_debit_note
    # end

    def add_purchase_return_note(purchase_return, remote_ip, amount)
      # gst debit note will be recorded against purchase return
      gst_debit_note=new_note(purchase_return.company)
      gst_debit_note.company_id=purchase_return.company.id
      gst_debit_note.created_by=purchase_return.created_by
      gst_debit_note.gst_debit_note_date=purchase_return.record_date
      gst_debit_note.created_by=purchase_return.account_id
      # gst_debit_note.description=purchase_return.customer_notes
      # gst_debit_note.branch_id=purchase_return.purchase.branch_id
      # gst_debit_note.read_only=true
      gst_debit_note.amount=amount
      gst_debit_note.purchase_return_id=purchase_return.id
      gst_debit_note.description="This voucher generated with reference of purchase return ##{purchase_return.purchase_return_number}"
      gst_debit_note.save(:validate=>false)
      gst_debit_note.register_user_action(remote_ip, 'created')
      gst_debit_note
    end

    def new_note(company)
      gst_debit_note = GstDebitNote.new
      gst_debit_note.company_id=company.id
      gst_debit_note.gst_debit_note_number = VoucherSetting.next_gst_debit_note_number(company)
      gst_debit_note
    end
    def create_note(params, company, user, fyr)
      gst_debit_note = GstDebitNote.new(params[:gst_debit_note])
      gst_debit_note.company_id = company
      gst_debit_note.created_by = user.id
      # gst_debit_note.branch_id = user.branch_id unless user.branch_id.blank?
      gst_debit_note.fin_year = fyr
      gst_debit_note
    end

    def update_note(params, company, user, fyr)
      gst_debit_note = DebitNote.find(params[:id])
      # gst_debit_note.branch_id = user.branch_id unless user.branch_id.blank?
      gst_debit_note.fin_year = fyr
      gst_debit_note
    end
  end
    def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip," #{gst_debit_note_number} for amount #{amount}", action,nil)
  end

    def save_with_ledgers
    save_result = false
    line_items = gst_debit_note_line_items
    transaction do
      if save
        random_str = Ledger.generate_secure_random
        line_items.each do |line_item|
        debit_ledger_entry = Ledger.new_debit_ledger(line_item.to_account_id, company_id, gst_debit_note_date, amount, gst_debit_note_number, created_by, nil, branch_id,random_str, from_account_id)
        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, gst_debit_note_date, amount, gst_debit_note_number, created_by, nil, branch_id,random_str, line_item.to_account_id)
        #build relationship between invoice and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
      end
      tax_line_items.each do |line_item|
         tax_account = line_item.account
         next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
         random_str=Ledger.generate_secure_random
         debit_ledger_entry = Ledger.new_gst_debit_ledger(line_item.account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, from_account_id)
         credit_ledger_entry = Ledger.new_gst_credit_ledger(from_account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, line_item.account_id)
         #build relationship between expense and ledgers
         ledgers << credit_ledger_entry
         ledgers << debit_ledger_entry
        end
        save_result = true
      end
    end
    save_result
  end

  #updating ledger entries in  case of edit actions
  def update_and_post_ledgers
    update_result = false;
    line_items = gst_debit_note_line_items
    transaction do
      if update
        Ledger.delete(ledgers)
        line_items.each do |line_item|
        random_str = Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(line_item.to_account_id, company_id, gst_debit_note_date, amount, gst_debit_note_number, created_by, nil, branch_id, random_str, from_account_id)
        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, gst_debit_note_date, amount, gst_debit_note_number, created_by, nil, branch_id, random_str, line_item.to_account_id)
        #build relationship between invoice and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
        end
        update_result = true
      end
    end
  end
  def delete(deleted_by_user)
    result = false
      transaction do
      if update_attributes(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
      ledgers.update_all(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)

      result = true
      end
    end
    result
  end

  #restore method
  def restore(restored_by_user)
    result = false
    transaction do
      if update_attributes(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
        ledgers.update_all(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
        result = true
      end
    end
  end

end