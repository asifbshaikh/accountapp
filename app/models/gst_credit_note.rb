class GstCreditNote < ActiveRecord::Base
  include VoucherBase

  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:gst_credit_note_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("gst_credit_note_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_from_account, lambda{|from_account| where(:from_account_id=>from_account) unless from_account.blank? }
  scope :by_to_account, lambda{|to_account| where(:to_account_id=>to_account) unless to_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:gst_credit_note_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  scope :by_status, lambda{|status| where(:status_id => status) unless status.blank?}

  belongs_to :account
  belongs_to :company
  has_many :ledgers, :as=>:voucher, :dependent=>:destroy
  has_many :gst_credit_allocations, :dependent=>:destroy
  has_many :gst_credit_note_line_items, :conditions=>{:line_type=>"GstCreditNoteLineItem"}, :dependent=>:destroy
  has_many :tax_line_items, :class_name=>"GstCreditNoteLineItem", :conditions=>{:line_type=>nil}, :dependent=>:destroy, :autosave=>true
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :invoice_return
  has_many :invoices , :through => :gst_credit_allocations

  accepts_nested_attributes_for :gst_credit_note_line_items
  accepts_nested_attributes_for :gst_credit_allocations, :reject_if=> lambda{|a| a[:amount].blank? || a[:amount].to_f<=0}, :allow_destroy => true
  #validations
   validates :gst_credit_note_number ,:gst_credit_note_date, :amount, :to_account_id, :presence=> true
   validates_uniqueness_of :gst_credit_note_number, :scope=>:company_id
   validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                         :message => " should not be zero or negative ." }

   #validate :validate_from_account_and_to_account

   # validate :save_only_in_current_year
  attr_accessor :fin_year
  validate :amount_allocation
  STATUS = {'0' => "open", '1' => "allocated", '2' => "refund"}
  GST_CREDIT_NOTE_STATUS = {Open: 0, Allocated: 1, Refund: 2}

  def voucher_setting
    VoucherSetting.by_voucher_type(27, company_id).first
  end


   def gst_line_items
    #create a hash with key as tax rate 
    #get the line item rate, check if the rate is present in hash
    #if not add a new gst_line_item_object to it
    #if present get the gst_line_item and add required fields to them
    items = Hash.new
    self.gst_credit_note_line_items.each do |line_item|
      rate = line_item.gst_tax_rate
      if items.has_key? rate
        gst_tax_item = items[rate]
        gst_tax_item.add_txn_value(line_item.amount)
        gst_tax_item.add_igst_amt(line_item.igst_amt)
        gst_tax_item.add_cgst_amt(line_item.cgst_amt)
        gst_tax_item.add_sgst_amt(line_item.sgst_amt)
      else
        items[rate] = GstInvoiceLineItem.new(rate, line_item.amount, line_item.igst_amt, line_item.cgst_amt, line_item.sgst_amt, nil)
      end
    end
    items.values
  end



  def total_amount
      amount
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

  def customer_GSTIN
    gstin = nil
    customer = self.to_account.customer
    if customer.present?
      gstin = customer.gstn_id
    end 
    gstin
  end

  def amount_allocation
    if amount<allocated_amount
      errors.add(:amount, "can't be greater than unallocated amount")
    end
  end

  def manage_invoice_status
    
    gst_credit_allocations.each do |allocation|
      allocation.invoice.update_invoice_status
    end
  end

  def allocated_amount
    amount=0
    gst_credit_allocations.each do |allocation|
      amount+=allocation.amount unless allocation.amount.blank?
    end
    amount
  end

  def group_tax_amt(account_id)
    amt = 0
    tax_items = self.tax_line_items.where(:account_id => account_id)
    tax_items.each do |item|
      amt += item.amount
    end
    amt
  end


  def discount
    discount = 0
    gst_credit_note_line_items.each do |line|
      discount += (line.unit_rate*line.quantity)*(line.discount_percent/100.0) unless line.amount.blank? || line.discount_percent.blank?
    end
    discount
  end


  def unallocated_amount
    amount-gst_credit_allocations.sum(:amount)
  end

  def manage_gst_credit_note_status
    if unallocated_amount == 0
      self.update_attribute(:status_id, 1)
    end
  end

  def currency
    code=company.currency_code
    code=invoice_return.currency unless invoice_return.blank?
    code
  end
 
  def get_product(tax_id)
  end

  def validate_from_account_and_to_account
    if self.from_account_id == self.to_account_id
      errors.add(:base, "Both accounts should not be same")
    end
    if !from_account.blank? && !gst_credit_note_date.blank? && from_account.start_date > gst_credit_note_date
      errors.add(:gst_credit_note_date, "must be after account activation, #{from_account.name} is activated since #{from_account.start_date}")
    end
    if !to_account.blank? && !gst_credit_note_date.blank? && to_account.start_date > gst_credit_note_date
      errors.add(:gst_credit_note_date, "must be after account activation, #{to_account.name} is activated since #{to_account.start_date}")
    end
  end

   def from_account_name
     from_account.name unless from_account.blank?
   end

  def to_account_name
    to_account.name unless to_account.blank?
  end

  def open?
    status_id == 0
  end

  def allocated?
    status_id == 1
  end

  def refund?
    status_id == 2
  end


   def customer_name
      self.account.name  unless self.account.blank?  
  end

  def sub_total
    self.gst_credit_note_line_items.sum(:amount)
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
       gst_credit_note=company.gst_credit_notes.find(params[:id])
       gst_credit_note.assign_attributes(params[:gst_credit_note])
       gst_credit_note
     end

     # def allocate_credit(params, company)
     #   gst_credit_note=company.gst_credit_notes.find(params[:id])
     #   # allocated_invoices = gst_credit_note.gst_credit_allocations
     #   # unallocated_invoices = company.invoices.not_in(allocated_invoices).by_customer(gst_credit_note.to_account_id).by_status(0).by_currency(gst_credit_note.to_account.get_currency_id)
     #   # unallocated_invoices.each do |invoice|
     #   #   gst_credit_allocation=GstCreditAllocation.new(:invoice_id=>invoice.id) 
     #   #   gst_credit_note.gst_credit_allocations<<gst_credit_allocation
     #   # end
     #   gst_credit_note
     # end

    def add_invoice_return_note(invoice_return, remote_ip, gst_credit_note_amount)
      voucher_setting = VoucherSetting.where(:company_id=>invoice_return.company.id, :voucher_type=> 27).first
      if  voucher_setting.voucher_number_strategy ==2
        gst_credit_note=return_invoice_new_note(invoice_return)
      else
        gst_credit_note=new_note(invoice_return.company)
      end
      gst_credit_note.company_id=invoice_return.company.id
      gst_credit_note.created_by=invoice_return.created_by
      gst_credit_note.gst_credit_note_date=invoice_return.record_date
      gst_credit_note.to_account_id=invoice_return.account_id
      gst_credit_note.from_account_id=invoice_return.account_id
      gst_credit_note.branch_id=invoice_return.invoice.branch_id
      gst_credit_note.read_only=true
      gst_credit_note.amount=gst_credit_note_amount
      gst_credit_note.invoice_return_id=invoice_return.id
      gst_credit_note.save(:validate=>false)
      gst_credit_note.register_user_action(remote_ip, 'created')
      gst_credit_note
    end
     def return_invoice_new_note(invoice_return)
       gst_credit_note = GstCreditNote.new
       gst_credit_note.company_id=invoice_return.company.id
       gst_credit_note.gst_credit_note_number =VoucherSetting.return_invoice_next_gst_credit_note_number(invoice_return)
       gst_credit_note
     end

     def new_note(company)
       gst_credit_note = GstCreditNote.new
       gst_credit_note.company_id=company.id
       gst_credit_note.gst_credit_note_number = VoucherSetting.next_gst_credit_note_number(company)
       gst_credit_note
     end

     def create_note(params, company, user, fyr)
       gst_credit_note = GstCreditNote.new(params[:gst_credit_note])
       gst_credit_note.company_id = company
       gst_credit_note.created_by = user.id
       gst_credit_note.branch_id = user.branch_id unless user.branch_id.blank?
       gst_credit_note.fin_year = fyr
       gst_credit_note
     end
     def update_note(params, company, user, fyr)
       gst_credit_note = GstCreditNote.find(params[:id])
       gst_credit_note.branch_id = user.branch_id unless user.branch_id.blank?
       gst_credit_note.fin_year = fyr
       gst_credit_note
     end
  end
  def register_user_action(remote_ip, action)
     Workstream.register_user_action(company_id, created_by, remote_ip," #{gst_credit_note_number} for amount #{amount}", action, branch_id)
  end
 #creating new ledger entry for new record
  def save_with_ledgers
    save_result = false
    line_items = gst_credit_note_line_items
    transaction do
      if save
        random_str = Ledger.generate_secure_random
        line_items.each do |line_item|
        debit_ledger_entry = Ledger.new_gst_debit_ledger(line_item.from_account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, to_account_id)
        credit_ledger_entry = Ledger.new_gst_credit_ledger(to_account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, line_item.from_account_id)
        #build relationship between invoice and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
      end
         tax_line_items.each do |line_item|
         tax_account = line_item.account
         next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
         random_str=Ledger.generate_secure_random
         debit_ledger_entry = Ledger.new_gst_debit_ledger(line_item.account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, to_account_id)
         credit_ledger_entry = Ledger.new_gst_credit_ledger(to_account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, line_item.account_id)
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
    line_items = gst_credit_note_line_items
    transaction do
      if update
        Ledger.delete(ledgers)
        random_str = Ledger.generate_secure_random
        line_items.each do |line_item|
        debit_ledger_entry = Ledger.new_gst_debit_ledger(line_item.from_account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, to_account_id)
        credit_ledger_entry = Ledger.new_gst_credit_ledger(to_account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, line_item.from_account_id)
        #build relationship between invoice and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
        end

        tax_line_items.reload
        tax_line_items.each do |line_item|
        tax_account = line_item.account
        next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_gst_debit_ledger(line_item.account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, to_account_id)
          credit_ledger_entry = Ledger.new_gst_credit_ledger(to_account_id, company_id, gst_credit_note_date, line_item.amount, gst_credit_note_number, created_by, branch_id, random_str, line_item.account_id)
          #build relationship between expense and ledgers
          ledgers << credit_ledger_entry
          ledgers << debit_ledger_entry
        end
        update_result = true
      end
    end
  end

  def get_total_amount
    amount=0
    gst_credit_note_line_items.each do |line_item|
      amount+=line_item.amount
    end
    tax_line_items.each do |line_item|
      tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
      amount+=line_item.amount unless line_item.marked_for_destruction?
    end
    amount
  end


 #soft delete method
  def delete(deleted_by_user)
    result = false
    transaction do
	if update_attributes(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
	ledgers.update_all(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)

  delete_gstr_one_entry
	result = true
	end
    end
    result
  end

  def delete_gstr_one_entry
    @gstr_one_credit_note = GstrOneItem.find_by_voucher_id_and_voucher_type(id,"GstCreditNote")
    @gstr_one_credit_note.destroy
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

  def get_status
     STATUS[status_id.to_s]
  end

 def gst_credit_notes(company)
    acc = self.accounts.find_all_by_company_id(company)
     if acc.blank?
      nil
    else
      acc
    end
 end
end
