class Invoice < ActiveRecord::Base
  include InvoiceBase
  include VoucherBase
  scope :this_year_and_previous_unpaid, lambda { |start_date, end_date| where("due_date between ? and ? or invoice_status_id=0", start_date, end_date) }
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  #[FIXME] check if the by date can be removed its actually by Financial year start date and end date
  scope :by_date, lambda{|fin_year| where(:invoice_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_financial_year, lambda{|fin_year| where(:invoice_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_due_date, lambda{|date| where(:due_date => date) unless date.blank?}
  scope :by_cash_invoice, lambda{|cash| where(:cash_invoice => cash) unless cash.blank?}
  scope :by_status, lambda{|status| where(:invoice_status_id => status) unless status.blank?}
  scope :by_month, lambda{|month| where(:invoice_date => month.beginning_of_month..month.end_of_month) unless month.blank?}
  scope :by_quarter, lambda{|quarter| where(:invoice_date => quarter.beginning_of_month-3.month..quarter.end_of_month) unless quarter.blank?}
  scope :by_week, lambda{|week| where(:invoice_date => week.beginning_of_week..week.end_of_week) unless week.blank?}
  scope :by_time_invoice, lambda{|time| where(:time_invoice => time) unless time.blank?}
  scope :by_day, lambda{|day| where(:invoice_date => day) unless day.blank?}
  scope :by_10day, lambda{|day| where(:invoice_date => day) unless day.blank?}
  scope :by_monthwise, lambda{|day| where(:invoice_date => day) unless day.blank?}
  scope :by_customer, lambda{|customer| where(:account_id=> customer) unless customer.blank? }
  scope :created_by, lambda{|user| where(:created_by=> user) unless user.blank? }
  scope :by_voucher, lambda{|voucher_no| where("invoice_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:due_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_invoice_date_range, lambda{|start_date, end_date| where(:invoice_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_settlement_date_range, lambda{|start_date, end_date| where(:updated_at=> start_date..end_date)}
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:total_amount=> min_amt..max_amt)}
  scope :by_project, lambda{|project| where(:project_id=>project.to_i) unless project.blank? }
  scope :by_custom_field, lambda{|custom_field| where("custom_field1 = ? or custom_field2 =? or custom_field3=? ",custom_field, custom_field, custom_field) unless custom_field.blank?}
  scope :not_in, lambda { |invoices| where("id not in(?)", invoices.map { |e| e.invoice_id }) unless invoices.blank?}
  scope :by_currency, lambda {|currency| where(:currency_id => currency) unless currency.blank?}

  has_one :recursion, :as => :recursive
  has_one :billing_address, :class_name=>'Address', :as=>:addressable, :conditions=>{:address_type=>1}
  has_one :shipping_address, :class_name=>'Address', :as=>:addressable, :conditions=>{:address_type=>0}

  belongs_to :company
  belongs_to :settlement_account, :class_name => "Account",:foreign_key => :settlement_account_id
  belongs_to :account
  belongs_to :customer
  belongs_to :vendor
  belongs_to :user, :foreign_key => :created_by
  #belongs_to :invoice_status
  belongs_to :project
  belongs_to :estimate
  #belongs_to :currency
  has_many :instamojo_payment_links
  has_many :cashfree_payment_links
  has_many :invoice_attachments, :dependent=>:destroy
  has_many :gst_credit_notes, :through => :gst_credit_allocations

  has_many :gstr_one_items, :as => :voucher, :dependent => :destroy
  has_many :invoice_line_items, :conditions => {:type => "InvoiceLineItem"}, :dependent => :destroy
  has_many :tax_line_items, :class_name => "InvoiceLineItem", :conditions => {:type => nil}, :dependent => :destroy
  has_many :shipping_line_items, :dependent => :destroy
  has_many :time_line_items, :dependent => :destroy
  #has_many :addresses, :as=>:addressable, :dependent=>:destroy
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_many :invoices_receipts
  has_many :gstr_advance_receipt_invoices
  has_many :gstr_advance_receipts, :through => :gstr_advance_receipt_invoices, :dependent => :destroy
  has_many :receipt_vouchers, :through=> :invoices_receipts, :dependent => :destroy
  has_many :invoice_sales_orders, :dependent => :destroy
  has_many :sales_orders, :through => :invoice_sales_orders
  has_many :invoice_returns, :dependent=>:destroy
  has_many :invoice_credit_allocations, :dependent=>:destroy
  has_many :gst_credit_allocations, :dependent=>:destroy
  has_many :invoice_histories, :order => "record_date DESC", dependent: :destroy

  accepts_nested_attributes_for :recursion, :billing_address, :shipping_address
  accepts_nested_attributes_for :invoice_line_items, :reject_if => lambda {|a| a[:product_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :tax_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :shipping_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :time_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  attr_accessible :current_step, :project_id, :financial_year_id, :settlement_exchange_rate, :settlement_account_id, :fin_year, :recursive_invoice, :invoice_number, :due_date, :invoice_date, :terms_and_conditions, :customer_notes, :po_reference, :invoice_status_id, :account_id, :so_invoice, :currency_id, :exchange_rate,
  :deleted, :deleted_datetime, :deleted_by, :restored_by, :restored_datetime, :invoice_line_items_attributes, :tax_line_items_attributes, :cash_customer_email,:total_amount,:voucher_title_id,:tax_inclusive,
  :cash_customer_mobile, :cash_customer_name, :cash_invoice,  :custom_field1, :custom_field2, :custom_field3, :shipping_line_items_attributes, :time_line_items_attributes, :time_invoice, :recursion_attributes, :billing_address_attributes,
  :shipping_address_attributes, :place_of_supply, :cash_customer_gstin, :export_invoice,:sbpcode,:sbnum, :sbdate
  #validations
  validates :custom_field1, :custom_field2, :custom_field3, :length => { :maximum => 30, :too_long => "%{count} characters is the maximum allowed" }
  validates_presence_of :account_id, :message => "Please select Customer", :allow_blank=>true
  validates_presence_of :invoice_number, :invoice_date
  validates_presence_of :due_date
  validates_presence_of :place_of_supply, :if => lambda{|e| (e.gst_invoice? && !e.export_invoice)}
  validates_uniqueness_of :invoice_number, :scope=>[:company_id, :financial_year_id]
  validates_presence_of :invoice_line_items, :if =>  lambda{|e| !e.draft? && !e.time_invoice? && !e.so_invoice? }
  validates_associated :invoice_line_items, :message => "fields with * are mandatory", :if =>  lambda{|e| !e.draft? && !e.time_invoice? && !e.so_invoice?}
  validates_associated :tax_line_items, :message => "fields with * are mandatory", :if =>  lambda{|e| e.invoice_status_id != 1 }
  validates_associated :shipping_line_items, :message => "fields with * are mandatory", :if =>  lambda{|e| e.invoice_status_id != 1 }
  validates_presence_of :time_line_items, :if =>  lambda{|e| e.invoice_status_id != 1 && e.time_invoice == true}
  validates_associated :time_line_items, :message => "fields with * are mandatory", :if =>  lambda{|e| e.invoice_status_id != 1 && e.time_invoice == 1 }
  validates_associated :recursion
  validate :invoice_date_and_due_date, :if =>  lambda{|e| e.invoice_status_id != 1 }
  # validate :save_only_in_current_year
  validates_format_of :cash_customer_email,
  :with =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
  :message => ":Its not a valid format", :allow_blank => true
  validate :available_inventory
  validate :validate_account_type, :if => lambda{|e| !e.account_id.blank? && !e.cash_invoice? }
  validate :save_in_frozen_fy
  validates_presence_of :exchange_rate, :if => lambda{|e| !e.account.blank? && !e.account.get_currency_id.blank?}
  validate :validate_exchange_rate, :if=>:exchange_rate
  validate :validate_tax_account, :if => lambda{|e| e.tax_inclusive? }
  validate :settlement
  validate :account_effective_date
  validate :ensure_stock_in_warehouse, :if=>lambda { |e| e.last_step?  }
  validates_presence_of :settlement_account_id, :if=>lambda{|e| e.settled? }

  attr_accessor :fin_year
  STATUS = {'1' => "draft", '2' => "paid", '0' => "unpaid", '3'=>"settled", '4' => "returned"}
  INVOICE_STATUS = { draft: 1, paid: 2, unpaid: 0, settled: 3, returned: 4}
  INVOICE_TYPE={true=>"draft", false=>'discharge'}
  SO_INVOICE={true=>"so", false=>"non_so"}
  SETTLEMENT_STATUS={true=>"settled", false=>"non_settled"}
  RETURN_STATUS={true=>'returned', false=>'non_returned'}
  INVOICE_GROUP={true=>'cash', false=>'credit'}
  attr_writer :current_step


  def draft?
    invoice_status_id == INVOICE_STATUS[:draft]
  end

  def gst_line_items
    #create a hash with key as tax rate 
    #get the line item rate, check if the rate is present in hash
    #if not add a new gst_line_item_object to it
    #if present get the gst_line_item and add required fields to them
    items = Hash.new
    self.invoice_line_items.each do |line_item|
      rate = line_item.gst_tax_rate
      if items.has_key? rate
        gst_tax_item = items[rate]
        gst_tax_item.add_txn_value(line_item.amount)
        gst_tax_item.add_igst_amt(line_item.igst_amt)
        gst_tax_item.add_cgst_amt(line_item.cgst_amt)
        gst_tax_item.add_sgst_amt(line_item.sgst_amt)
      else
        items[rate] = GstInvoiceLineItem.new(rate, line_item.amount, line_item.igst_amt, line_item.cgst_amt, line_item.sgst_amt, place_of_supply)
      end
    end
    items.values
  end



  def get_product_wise_summary

    items = Hash.new
    self.invoice_line_items.each_with_index do |line_item,index|
       rate = line_item.gst_tax_rate
       item = line_item.product
  
        items[item.hsn_code] = ProductWiseSummary.new(item.hsn_code, item.description[0..29], item.unit_of_measure,
          line_item.quantity, line_item.amount, line_item.igst_amt, line_item.cgst_amt, line_item.sgst_amt)
    
    end
    items.values



  end


  def intra_state_supply
    company.gstn_state_code == place_of_supply.rjust(2, '0')
  end


  def contains_zero_gst_tax_line_item?
    result = false
    tax_line_items.each do |line_item|
      if line_item.is_zero_gst_tax_line_item?
        result = true
        break
      end  
    end
    result
  end

  def zero_item_taxable_value
    taxable_amt = 0
    invoice_line_items.each do |line_item|
      #Rails.logger.debug "====Zero Item calculation================#{line_item.inspect}=========="
      line_item.invoice_taxes.each do |inv_tax|
        if inv_tax.account.name.include? "@Zero"
          taxable_amt += line_item.amount * exchange_rate
        end 
      end  
    end
    taxable_amt
  end

  def contains_igst_tax_line_item?
    result = false
    tax_line_items.each do |line_item|
      if line_item.is_igst_tax_line_item?
        result = true
        break
      end  
    end
    result
  end

  def contains_nil_gst_tax_line_item?
    result = false
    tax_line_items.each do |line_item|
      if line_item.is_nil_gst_tax_line_item?
        result = true
        break
      end  
    end
    result
  end

  def nil_item_taxable_value
    taxable_amt = 0
    invoice_line_items.each do |line_item|
      line_item.invoice_taxes.each do |inv_tax|
        if inv_tax.account.name.include? "@Nil"
          taxable_amt += line_item.amount * exchange_rate
        end 
      end  
    end
    taxable_amt
  end

  def igst_tax_amt
    @igst_tax_amt ||= calc_igst_tax_amt
  end

  def cgst_tax_amt
    @cgst_tax_amt ||= calc_cgst_tax_amt
  end

  def sgst_tax_amt
    @sgst_tax_amt ||= calc_sgst_tax_amt
  end


  def calc_igst_tax_amt
    igst_tax_amt = 0
    tax_line_items.each do |line_item|
      #Rails.logger.debug "==========#{line_item.account.name} #{line_item.amount}======"
      act_name = line_item.account.name
      if act_name.include? "IGST"
        igst_tax_amt += line_item.amount
      end
    end
    igst_tax_amt
  end

  def calc_cgst_tax_amt
    cgst_tax_amt = 0
    tax_line_items.each do |line_item|
      #Rails.logger.debug "==========#{line_item.account.name} #{line_item.amount}======"
      act_name = line_item.account.name
      if act_name.include? "CGST"
        cgst_tax_amt += line_item.amount
      end  
    end
    cgst_tax_amt
  end

  def calc_sgst_tax_amt
    sgst_tax_amt = 0
    tax_line_items.each do |line_item|
      #Rails.logger.debug "==========#{line_item.account.name} #{line_item.amount}======"
      act_name = line_item.account.name
      if act_name.include? "SGST"
        sgst_tax_amt += line_item.amount
      end  
    end
    sgst_tax_amt
  end

  def place_of_supply_state
    State.find_by_state_code(self.place_of_supply).name
  end

  # DRAFT_INVOICE_CATEGOTY
  # DISCHARGE_INVOICE_CATEGORY

  # def shipping_address
  #   addresses.where(:address_type=>0).first
  # end
  # def billing_address
  #   addresses.where(:address_type=>1).first
  # end
  def has_batch_products_included?
    result=false
    invoice_line_items.each do |line_item|
      result=true if !line_item.product.blank? && line_item.product.batch_enable? && !line_item.marked_for_destruction?
    end
    result
  end

  def ensure_stock_in_warehouse
    invoice_line_items.each do |line_item|
      if line_item.inventoriable? && !line_item.marked_for_destruction?
        line_item.sales_warehouse_details.each do |swd|
          stock=Stock.find_by_warehouse_id_and_product_id(swd.warehouse_id, swd.product_id)
          if !stock.blank? && !swd.quantity.blank? && stock.quantity < swd.quantity
            errors.add(:base, "#{line_item.product.name}: low stock in #{swd.warehouse.name}")
          end
        end
      end
    end
  end

  def save_as_draft
    transaction do
      #why keep back inventory
      keep_back_inventory
      save!(:validate=>false)
      set_sales_warehouse_detail_status
      update_attribute("total_amount", calculate_total_amount)
    end
  end

  def has_atleast_one_inventoriable_item?
    result=false
    invoice_line_items.each do |line_item|
      result=true if !line_item.product.blank? && line_item.inventoriable? && !line_item.marked_for_destruction?
    end
    result
  end
  # -------For multi step form---------------
  def steps
    %w[first last]
  end

  def current_step
    @current_step || steps.first
  end

  def first_step
    self.current_step=steps.first
  end

  def last_step
    self.current_step=steps.last
  end

  def first_step?
    current_step==steps.first
  end
  
  def last_step?
    current_step == steps.last
  end

  # --------End------------
  def create_fresh_warehouse_details
    #This method will created sales warehouse details for single warehouse companies(Manjeet)
    if !company.has_more_than_one_warehouses? && !draft?
      invoice_line_items.each do |line_item|
        if !line_item.product.blank? && line_item.inventoriable?
          sales_warehouse_detail=SalesWarehouseDetail.new(:warehouse_id=>company.default_warehouse.id,
            :quantity=>line_item.quantity, :product_id=> line_item.product_id)
          line_item.sales_warehouse_details<<sales_warehouse_detail
        end
      end
    end
  end

  def update_invoice_with_details(params, view_context, user, remote_ip, financial_year)

    # last_step #their are some validations to be run on last step only. Considering final save will be always last step.
    transaction do
      keep_back_inventory
      create_fresh_warehouse_details unless has_batch_products_included? #Will execute in case single warehouse only
      if valid?
        if so_invoice?
          sales_orders.first.update_billing_status unless sales_orders.blank?
        else
          first_recursion=original_invoice.draft? && recursive_enabled? && params[:recursive] == '1'
          # set_sales_warehouse_detail_status
          update_inventory
          # reload
          save(validate: false)
          # reload
        end

        create_invoice_history(id, company_id, user.id, "updated")
        update_and_post_ledgers
        register_user_action(remote_ip, 'updated')
        update_invoice_status unless cash_invoice?

        if first_recursion
          send_to_both_parties(self, view_context)
        elsif recursive_invoice? && active_recursion?
          recursion.change_frequency_and_create_invoice(view_context, financial_year)
        end
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  def account_effective_date
    if !account.blank? && !invoice_date.blank? && invoice_date < account.start_date
      errors.add(:invoice_date, "must be after account activation, #{account.name} is activated since #{account.start_date}")
    end
  end

  def has_credit_allocation_any?
    !invoice_credit_allocations.blank?
  end

  def has_gst_credit_allocation_any?
    allocated_gst_credit != 0
  end

  def allocated_credit
    invoice_credit_allocations.sum(:amount)
  end

  def allocated_gst_credit
    gst_credit_allocations.sum(:amount)
  end

  def credit_note_amount
    invoice_returns.sum(:total_amount)
  end

  def has_return_any?
    !invoice_returns.blank?
  end

  def invoice_type
    case true
    when self.cash_invoice?
      "cash_invoice"
    when self.time_invoice?
      "time_invoice"
    when self.so_invoice?
      "so_invoice"
    else
      "credit_invoice"
    end
  end

  def fully_returned?
    result=true
    invoice_line_items.each do |line_item|
      if result
        result= (line_item.quantity==line_item.invoice_return_line_items.sum(:quantity))
      end
    end
    result
  end

  def settlement
    if settled? && foreign_currency? && (settlement_exchange_rate.blank? || settlement_exchange_rate<=0)
      errors.add(:exchange_rate, "must be present.")
    end
  end

  def validate_tax_account
    self.invoice_line_items.each do |line_item|
      if line_item.invoice_taxes.blank?
        errors.add(:base,"Tax can not be blank for tax inclusive invoice.")
      end
    end
  end

  def settled?
    invoice_status_id==3
  end

  def unpaid?
    invoice_status_id==0
  end

  def paid?
    invoice_status_id==2
  end

  def overdue_days
    Time.zone.now.to_date - self.due_date
  end

  def outstanding
    amount=return_substracted_outstanding
    amount<0? 0 : amount
  end

  ##Dead code need to be updated
  def expense_amount
    amount= outstanding*0.019*(1+0.15)
    amount

  end
  ##############################


  def cashfreeid
    cashfreeid="CF"+"-"+id.to_s+"-"+invoice_number.gsub('/', '')
    cashfreeid
  end



  def update_status_and_create_adjustment_ledger_entries
    transaction do
      if save
        if STATUS[invoice_status_id.to_s]=="settled"
          settlement_amount= foreign_currency? ? outstanding*settlement_exchange_rate : outstanding
          random_str=Ledger.generate_secure_random
          debit_ledger_entry=Ledger.new_debit_ledger(settlement_account_id, company_id, invoice_date,
            settlement_amount, invoice_number, created_by, "", branch_id, random_str, account_id)

          credit_ledger_entry=Ledger.new_credit_ledger(account_id, company_id, invoice_date,
            settlement_amount, invoice_number, created_by, "", branch_id, random_str, settlement_account_id)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
      end
    end
  end

  def has_recorded_recursion?
    !Recursion.find_by_id(recursion.id).blank?
  end

  def set_sales_warehouse_detail_status
    invoice_line_items.each do |line_item|
      line_item.set_sales_warehouse_detail_status
    end
  end

  def original_invoice
    Invoice.find id
  end

  def draft?
    invoice_status_id==1
  end

  def pdf_column_count
  # Method is only for pdf use. Method requires modification in case any column added or removed in future.(Manjeet)
  # if discount>0
  #   if tax>0
  #     5
  #   else
  #     3
  #   end
  # else
  #   if tax>0
  #     4
  #   else
  #     2
  #   end
  # end
  count=2
  count+=2 if tax>0
  count+=1 if discount>0
  count
  end


  # def foreign_currency?
  #   !currency_id.blank? && !exchange_rate.blank? && exchange_rate != 0 && company.currency_code != currency
  # end

  def validate_exchange_rate
    account = Account.find_by_id(account_id)
    unless account.blank?
      customer_currency = account.get_currency
      if !customer_currency.blank? && company.currency_code != customer_currency
        if exchange_rate <= 0
          errors.add(:exchange_rate, "should not be zero or negative")
        end
      end
    end
  end

  def update_exist_receipts_with_ledger
    receipt_vouchers.each do |receipt_voucher|
      if receipt_voucher.advanced?
        receipt_voucher.update_attribute("allocated", false) if receipt_voucher.allocated?
        receipt_voucher.update_and_post_ledgers
      else
        receipts = receipt_voucher.invoices_receipts.where(:deleted=>false)
        receipt = ReceiptVoucher.find receipt_voucher.id
        receipt.amount=0
        receipt.tds_amount=0
        receipts.each do |ir|
          receipt.amount += ir.amount unless ir.amount.blank?
          receipt.tds_amount += ir.tds_amount unless ir.tds_amount.blank?
        end
        receipt.payment_detail.amount = receipt_voucher.amount
        receipt.save
        receipt.update_and_post_ledgers
      end
    end
  end

  def save_received_amount_as_advance
    invoices_receipts.each do |invoice_receipt|
      unless invoice_receipt.receipt_voucher.advanced?
        if invoice_receipt.receipt_voucher.invoices_receipts.count==1
          invoice_receipt.receipt_voucher.update_attributes(:advanced=>true, :allocated=>false)
        else
          receipt_voucher = ReceiptVoucher.new
          receipt_voucher.received_date = Time.zone.now.to_date
          receipt_voucher.voucher_date = Time.zone.now.to_date
          receipt_voucher.voucher_number = VoucherSetting.next_receipt_voucher_number(company)
          receipt_voucher.company_id = company_id
          receipt_voucher.created_by = created_by
          receipt_voucher.project_id = project_id
          receipt_voucher.from_account_id = account_id
          receipt_voucher.to_account_id = invoice_receipt.receipt_voucher.to_account_id
          receipt_voucher.currency_id = invoice_receipt.receipt_voucher.currency_id
          receipt_voucher.exchange_rate = invoice_receipt.receipt_voucher.exchange_rate
          receipt_voucher.amount=invoice_receipt.amount
          receipt_voucher.tds_amount=invoice_receipt.tds_amount
          receipt_voucher.tds_account_id = Account.find_by_name_and_company_id("tds receivable", company).id
          receipt_voucher.branch_id = branch_id
          receipt_voucher.allocated=false
          receipt_voucher.advanced=true
          receipt_voucher.build_payment_detail
          receipt_voucher.payment_detail=invoice_receipt.receipt_voucher.payment_detail.class.to_s.constantize.new(invoice_receipt.receipt_voucher.payment_detail.attributes)
          # receipt_voucher.payment_detail.assign_attributes(invoice_detail.receipt_voucher.payment_detail.attributes) #Invoice.fetch_payment_details(invoice_detail.receipt_voucher.payment_detail)
          receipt_voucher.payment_detail.payment_date=Time.zone.now.to_date if receipt_voucher.payment_detail.class.to_s=="CashPayment"
          receipt_voucher.payment_detail.amount=receipt_voucher.amount
          receipt_voucher.save!
          invoice_receipt.update_attribute("deleted", true)
          sleep(0.5)
        end
      end
    end
  end

  def save_in_frozen_fy
    if !invoice_date.blank? && in_frozen_year?
      errors.add(:invoice_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, invoice_date)
  end

  # def balance_due
  #   total_amount - paid_amount
  # end

  #[FIXME] can this be made part of receipt voucher. i.e. the amount paid should include
  # both amount and the tds_amount
  def paid_amount
    if gst_invoice?
      self.gstr_advance_receipt_invoices.sum(:amount) + self.invoices_receipts.sum(:amount) + self.invoices_receipts.sum(:tds_amount)
    else
    self.invoices_receipts.sum(:amount) + self.invoices_receipts.sum(:tds_amount)
  end
end

  #[FIXME] This method has been depricated. Please do not use it any more
  #Naveen 28-Jul-2017
  def get_party
    account.customer.blank? ? account.vendor : account.customer
  end

  def get_vat_no
    if !cash_invoice? && !account.blank?
      get_party.vat_tin
    end
  end

  def total_sold(product)
    invoice_line_items.where(:product_id=>product).sum(:quantity)
  end

  def validate_account_type
    if !["SundryDebtor","SundryCreditor"].include?(Account.find(account_id).accountable_type)
      errors.add(:account_id,"you entered is not a customer, please select right account")
    end
  end

  def email_recursive_invoice(text, view_context ,to_email, receiver, subject)
    template= Invoice.get_template(company, "Invoice", "no")
    template_id= Template.find_by_template_name(template)
    @margin = TemplateMargin.find_by_template_id_and_company_id(template_id, company)

    custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(company.id, "Invoice", true)
    pdf = InvoicePdf.new(self, view_context, template, @margin, custom_field, invoice_line_items, time_line_items, shipping_line_items, tax_line_items, receipt_vouchers, 'Original')
    attachment = pdf.render
    unless to_email.blank?
      Email.send_invoice(attachment, self, company, company.users.first, subject, text, to_email, "").deliver
    end
  end

  def schedule_on_today?
    upcoming_schedule = recursion.get_upcoming_schedule
    Time.zone.now.to_date == upcoming_schedule
  end

  def reached_recursion_count?
    !recursion.iteration.blank? && !recursion.utilized_iteration.blank?  && recursion.iteration <= recursion.utilized_iteration
  end

  def stock_available?
    result = true
    if company.plan.is_inventoriable?
      invoice_line_items.each do |line|
        if line.product.inventoriable?
          warehouse_details = line.sales_warehouse_details
          warehouse_details.each do |swd|
            available_stock = Stock.available_in_warehouse(line.product.id, swd.warehouse_id)
            if available_stock < swd.quantity
              result=false
            end
          end
        end
      end
    end
    result
  end

  def active_recursion?
    !recursion.blank? && recursion.status == true
  end
  def inactive_recursion?
    !recursion.blank? && recursion.status == false
  end
  def recursive_enabled?
    !recursion.blank? && !recursion.frequency.blank? && !recursion.schedule_on.blank?
  end

  def recursive_invoice?
    recursive_invoice == 1
  end


  # def check_stock
  #   result = true
  #   prd_arr = []
  #   if company.plan.is_inventoriable?
  #     invoice_line_items.each do |line|
  #       if line.product.inventoriable?
  #         warehouse_details = line.sales_warehouse_details
  #         warehouse_details.each do |swd|
  #           available_stock = Stock.available_in_warehouse(line.product.id, swd.warehouse_id)
  #           if available_stock < swd.quantity
  #             result=false
  #             prd_arr<<"#{line.product.name}"
  #           end
  #         end
  #       end
  #     end
  #   end
  #   result
  #   prd_arr
  # end

  def available_inventory
    # warehouse_stocks ={}
    invoice_line_items.each do |line|
      if !line.product.blank? && line.inventoriable?
        existing_line=InvoiceLineItem.find_by_id line.id
        available_quantity=line.product.quantity #total available quatity from all warehouses
        available_quantity+=existing_line.quantity unless existing_line.blank? || existing_line.quantity.blank?
        if !line.quantity.blank? && (line.quantity > available_quantity)
          errors.add(:base, "low stock for #{line.product.name}")
        end
      end
    end
  end


  #[FIXME] This code should not be present in Model; shift to view/email
  def send_to_both_parties(parent_invoice, view_context)
    text = "A new invoice has been created and sent to #{account.name} automatically. Please refer to attached PDF for more details.<br /><br />"
    text += "<b>Invoice Details</b><br />----------------------<br />"
    text += "Invoice number:#{invoice_number}<br />For Customer:#{account.name}<br />Amount:#{total_amount}<br />Date:#{Time.zone.now.to_date}<br />Next auto-generation date:#{parent_invoice.recursion.schedule_on + parent_invoice.recursion.utilized_iteration.days unless parent_invoice.recursion.utilized_iteration.blank?}"
    email_recursive_invoice(text.html_safe, view_context, company.users.first.email, company.users.first.first_name, "New invoice created") unless company.users.first.email.blank?
    text = "A new invoice has been created for you and attached with this mail. Below is a brief summary.<br /><br />"
    text += "<b>Invoice Details</b><br />----------------------<br />"
    text += "Invoice number:#{invoice_number}<br />For Customer:#{account.name}<br />Amount:#{total_amount}<br />Date:#{Time.zone.now.to_date}<br />Due date:#{due_date}"
    customer = get_party
    email_recursive_invoice(text.html_safe, view_context ,customer.email, account.name, "New invoice created") unless customer.email.blank?
  end


  class << self

    # Returns an Array of total invoice amounts for each day in the given date range.
    #
    # Example
    # Invoice.daily_income_amounts(company, '01-03-2015','05-03-2015', user)
    # will return [249669.0,22886.0,0,0,143020.0]
    # where 249669.0 is the invoice total amount for '01-03-2015' and so on.
    # Total will be Zero if there are no invoices for a given date.
    def daily_income_amounts(company, start_date, end_date, user)
      daily_incomes = Invoice.select("invoice_date, sum(total_amount) as total")
        .where(:company_id=> company.id, :deleted => false, :invoice_date=> start_date..end_date, :branch_id=> user.branch_id).where("invoice_status_id !=1")
        .group("invoice_date")
      #the below code in to convert the ActiveRecord:Relation into a hash with key value mapping as 'transaction_date' => total
      daily_hash = Hash[daily_incomes.map {|invoice| [invoice.invoice_date, invoice.total]}]
      daily_invoice_totals = Array.new
      #code to add entries for dates that don't have any invoices
      start_date.upto(end_date) do |date|
        daily_invoice_totals.push(daily_hash[date].blank? ? 0 : daily_hash[date])
      end
      daily_invoice_totals
    end

    # Returns an Array of total invoice amounts for each month in the given date range.
    #
    # Example
    # Ledger.monthly_income_amounts(company, '01-01-2015','05-03-2015', user)
    # will return [249669.0,22886.0,0,0,143020.0]
    # where 249669.0 is the invoice total amount for '01-2015' and so on.
    # Total will be Zero if there are no invoices for a given month.
    def monthly_income_amounts(company, start_date, end_date, user)
      monthly_incomes = Invoice.select("DATE_FORMAT(invoice_date,'%m-%y') as month, sum(total_amount) as total")
        .where(:company_id=> company.id, :deleted => false, :invoice_date=> start_date..end_date, :branch_id=> user.branch_id).where("invoice_status_id !=1")
        .group("month(invoice_date)")
      #the below code in to convert the ActiveRecord:Relation into a hash with key value mapping as 'transaction_date' => total
      monthly_hash = Hash[monthly_incomes.map {|invoice| [invoice.month, invoice.total]}]
      date_range = start_date..end_date
      date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
      date_months = date_months.map {|d| d.strftime "%m-%y" }
      monthly_invoice_totals = Array.new

      # code to add entries for dates that don't have any invoices
      date_months.each do |date|
        monthly_invoice_totals.push(monthly_hash[date].blank? ? 0 : monthly_hash[date])
      end
      monthly_invoice_totals
    end

    
    def invoice_records(account,company,start_date, end_date)
      logger.debug " =============account is #{account.id}============"
       begin
      invoices = company.invoices
        invoices = invoices.by_customer(account) if account.present?
       invoices = invoices.by_invoice_date_range(start_date, end_date)
    rescue Exception => e
       logger.error "Exception raised #{e}"
       invoices = nil
      end
      invoices
    end
  

    def sales_register_records(search_by_user, user, account, company, start_date, end_date, branch_id)
      begin
        invoices = company.invoices.includes(:user).includes(:customer)
        invoices = invoices.created_by(search_by_user) if search_by_user.present?
        invoices = invoices.by_customer(account) if account.present?
        invoices = invoices.by_invoice_date_range(start_date, end_date) if start_date.present? || end_date.present?
        invoices = invoices.by_branch_id(branch_id) if branch_id.present? && user.owner?
        invoices = invoices.order("id DESC")
      rescue Exception => e
        logger.error "Exception raised #{e}"
        invoices = nil
      end
      invoices
    end

    def copy_into_new(source_object, user, company, financial_year, remote_ip)
      obj_type=source_object.class.to_s
      invoice = Invoice.new
      customer = source_object.get_party
      invoice.financial_year_id=financial_year.id
      invoice.company_id = source_object.company_id
      invoice.account_id = source_object.account_id
      invoice.invoice_date = Time.zone.now.to_date
      invoice.branch_id=source_object.branch_id
      invoice.due_date = (customer.class.to_s=="Customer" && !customer.credit_limit.blank?) ? (Time.zone.now.to_date+customer.credit_days.days) : Time.zone.now.to_date.advance(:weeks =>1)
      invoice.created_by = user.id
      invoice.invoice_number = company.invoice_setting.invoice_number
      invoice.invoice_status_id = 1
      invoice.so_invoice=1 if obj_type=="SalesOrder"
      invoice.billing_address=Address.new(invoice.get_party.billing_address.attributes) unless invoice.get_party.blank? || invoice.get_party.billing_address.blank?
      invoice.shipping_address=Address.new(invoice.get_party.shipping_address.attributes) unless invoice.get_party.blank? || invoice.get_party.shipping_address.blank?
      if source_object.foreign_currency?
        invoice.currency_id = source_object.currency_id
        invoice.exchange_rate = source_object.exchange_rate
      end

      if obj_type=="SalesOrder"
        if source_object.gst_salesorder?
          invoice.gst_invoice = true
          invoice.place_of_supply = source_object.place_of_supply
        end
        invoice.customer_notes = company.customer_note
        invoice.terms_and_conditions = company.terms_and_conditions
        invoice.project_id=source_object.project_id
        invoice.po_reference=source_object.po_reference
      else
        invoice.customer_notes = source_object.customer_notes
        invoice.terms_and_conditions = source_object.terms_and_conditions
      end

      if obj_type=="Estimate"
        if source_object.gst_estimate?
          invoice.gst_invoice =true
        end
        if source_object.export_estimate?
          invoice.export_invoice =true
        end  
        invoice.tax_inclusive=source_object.tax_inclusive
        invoice.estimate_id=source_object.id
        if source_object.customer_notes.present?
          invoice.customer_notes = source_object.customer_notes
        else  
          invoice.customer_notes = company.customer_note
        end
        if source_object.terms_and_conditions.present?
          invoice.terms_and_conditions = source_object.terms_and_conditions
        else
          invoice.terms_and_conditions = company.terms_and_conditions
        end
      end
      if obj_type=="Invoice"
        if source_object.gst_invoice?
          invoice.gst_invoice = true
        end
        invoice.project_id=source_object.project_id
        invoice.cash_invoice=source_object.cash_invoice
        invoice.cash_customer_email=source_object.cash_customer_email
        invoice.cash_customer_name=source_object.cash_customer_name
        invoice.cash_customer_mobile=source_object.cash_customer_mobile
        invoice.custom_field1=source_object.custom_field1
        invoice.custom_field2=source_object.custom_field2
        invoice.custom_field3=source_object.custom_field3
        invoice.time_invoice=source_object.time_invoice
        invoice.total_amount=source_object.total_amount
        invoice.voucher_title_id=source_object.voucher_title_id
        invoice.tax_inclusive=source_object.tax_inclusive
        if source_object.customer_notes.present?
          invoice.customer_notes = source_object.customer_notes
        else  
          invoice.customer_notes = company.customer_note
        end
        if source_object.terms_and_conditions.present?
          invoice.terms_and_conditions = source_object.terms_and_conditions
        else
          invoice.terms_and_conditions = company.terms_and_conditions
        end

        source_object.time_line_items.each do |line_item|
          time_line_item = TimeLineItem.new(
            :task_id => line_item.task_id,
            :quantity => line_item.quantity,
            :unit_rate => line_item.unit_rate,
            :discount_percent => line_item.discount_percent,
            :amount => line_item.amount,
            :description => line_item.description
            )
          line_item.send("#{source_object.class.to_s.underscore}_taxes").each do |tax|
            time_line_item.invoice_taxes<< InvoiceTax.new(:account_id=>tax.account_id)
          end
          invoice.time_line_items<<time_line_item
        end
      end

      source_object.shipping_line_items.each do |line_item|
        shipping_line_item = ShippingLineItem.new(
          :account_id => line_item.account_id,
          :amount => line_item.amount
          )
        invoice.shipping_line_items << shipping_line_item
      end

      source_object.send("#{source_object.class.to_s.underscore}_line_items").each do |line_item|
        quantity=(obj_type=="SalesOrder" ? line_item.ready_to_invoice : line_item.quantity)
        if quantity>0
          invoice_line_item = InvoiceLineItem.new(
            :product_id => line_item.product_id,
            :quantity => quantity,
            :unit_rate => line_item.unit_rate,
            :discount_percent => line_item.discount_percent,
            :amount => (obj_type=="SalesOrder" ? line_item.dlqty_amount : line_item.amount),
            :description => line_item.description,
            :type=>"InvoiceLineItem"
            )
          if obj_type=="Invoice" && company.plan.is_inventoriable?
            line_item.sales_warehouse_details.each do |swd|
              sales_warehouse_detail=SalesWarehouseDetail.new(swd.attributes)
              sales_warehouse_detail.id=nil
              sales_warehouse_detail.draft=1
              invoice_line_item.sales_warehouse_details<<sales_warehouse_detail
            end
          end
          line_item.send("#{source_object.class.to_s.underscore}_taxes").each do |tax|
            invoice_line_item.invoice_taxes<< InvoiceTax.new(:account_id=>tax.account_id)
          end
          invoice.invoice_line_items<<invoice_line_item
        end
      end

      invoice.save!(:validate=>false)
      invoice.build_tax
      invoice.total_amount=invoice.calculate_total_amount
      invoice.save!(:validate=>false)
      invoice.register_user_action(remote_ip, 'created')
      invoice
    end

    def create_with_delivery_challan(sales_order, delivery_challan, user, company)
      invoice = Invoice.new
      customer = sales_order.get_party
      invoice.company_id = sales_order.company_id
      invoice.account_id = customer.account.id
      invoice.invoice_date = Time.zone.now.to_date
      invoice.branch_id=sales_order.branch_id
      invoice.due_date = (customer.class.to_s=="Customer" && !customer.credit_limit.blank?) ? (Time.zone.now.to_date+customer.credit_limit.days) : Time.zone.now.to_date.advance(:weeks =>1)
      invoice.created_by = user
      invoice.invoice_number = company.invoice_setting.invoice_number
      invoice.invoice_status_id = 0
      invoice.so_invoice = true
      invoice.billing_address=Address.new(invoice.get_party.billing_address.attributes) unless invoice.get_party.blank? || invoice.get_party.billing_address.blank?
      invoice.shipping_address=Address.new(invoice.get_party.shipping_address.attributes) unless invoice.get_party.blank? || invoice.get_party.shipping_address.blank?
      invoice.terms_and_conditions = company.terms_and_conditions
      invoice.customer_notes = company.customer_note
      invoice.project_id=sales_order.project_id
      if sales_order.foreign_currency?
        invoice.currency_id=sales_order.currency_id
        invoice.exchange_rate=sales_order.exchange_rate
      end

      sales_order.sales_order_line_items.each do |line_item|
        if line_item.dc_quantity>0
          invoice_line_item = InvoiceLineItem.new(
            :product_id => line_item.product_id,
            :quantity => line_item.dc_quantity,
            :unit_rate => line_item.unit_rate,
            :discount_percent => line_item.discount_percent,
            :amount => line_item.dcamt,
            :description => line_item.description,
            :type=>"InvoiceLineItem"
            )
          sales_warehouse_detail = SalesWarehouseDetail.new(:warehouse_id => delivery_challan.warehouse_id,
            :quantity => line_item.dc_quantity, :product_batch_id=>line_item.product_batch_id, :product_id=>line_item.product_id)
          invoice_line_item.sales_warehouse_details << sales_warehouse_detail
          line_item.tax_accounts.each do |account|
            invoice_line_item.invoice_taxes<<InvoiceTax.new(:account_id=>account.id)
          end
          invoice.invoice_line_items<<invoice_line_item
        end
      end

      invoice.build_tax

      invoice.total_amount=invoice.calculate_total_amount

      if invoice.save_with_ledgers
        if invoice.company.plan.is_inventoriable?
          invoice.invoice_line_items.each do |line_item|
            if line_item.inventoriable?
              line_item.sales_warehouse_details.each do |swd|
                Stock.reduce(invoice.company_id, line_item.product_id, swd.warehouse_id, swd.quantity)
              end
            end
          end
        end
        invoice.invoice_sales_orders << InvoiceSalesOrder.new(:invoice_id=> invoice.id, :sales_order_id=> sales_order.id)
        sales_order.update_billing_status
      end
      invoice
    end

    def get_customer_invoices(company, account)
      where(:company_id => company, :account_id => account, :deleted => false)
    end

    def get_customer_unpaid_invoices(company, account)
      where(:company_id => company, :account_id => account, :deleted => false, :invoice_status_id => 0)
    end

    #[FIXME] I think this method is incorrect and giving wrong information. To be deleted
    def overdue_invoices(company,year, user)
      invoices = company.invoices.by_date(year).by_status(0).by_branch_id(user.branch_id)
      @due_invoices = []
      invoices.each do |i|
        @due_invoices << i if i.due_date < Time.zone.now.to_date
      end
      @due_invoices
    end

    def paid_invoices(company,year, user)
      company.invoices.by_status(2).by_date(year).by_branch_id(user.branch_id)
    end

    def unpaid_invoices(company,year, user)
      company.invoices.by_status(0).by_date(year).by_branch_id(user.branch_id)
    end

    def get_paybles(company,year, user)
      invoices = company.invoices.by_status(0).by_date(year).by_branch_id(user.branch_id)
      @payble_invoices = []
      invoices.each do |i|
        @payble_invoices << i if i.due_date == Time.zone.now.to_date
      end
      @payble_invoices
    end

    # Gets the invoices counts in current year grouped by their status for owner and accountant
    # If user is sales role then only the user created invoice counts are retrieved.
    def invoices_status_count(company, fin_year, user)
      if user.sales?
        invoice_counts=where("company_id = ? and created_by = ?", company.id, user.id).by_date_range(fin_year.start_date, Time.zone.now.to_date)
        .by_branch_id(user.branch_id).group(:invoice_status_id).order("invoice_status_id ASC").count
      else
        invoice_counts=where("company_id = ?", company.id).by_date_range(fin_year.start_date, Time.zone.now.to_date)
        .by_branch_id(user.branch_id).group(:invoice_status_id).order("invoice_status_id ASC").count
      end
    end

    # Returns top 5 overdue invoices by total invoice amounts. The outstanding
    # amounts are not calculated. Its just overdue invoices that have not received any payment.
    # If the user is of role sales then only invoices created by that user are displayed.
    def top_5_unpaid_invoices(company, year, user)
      #company.invoices.by_date(year).by_date_range(year.start_date, Time.zone.now.to_date).by_status(0).by_branch_id(user.branch_id).order("due_date DESC").limit(5)
      if user.sales?
        company.invoices.includes(:account).where("due_date <= ? and created_by = ?", Time.zone.now.to_date, user.id)
      .by_status(0).by_branch_id(user.branch_id).order("total_amount DESC, due_date ASC").limit(5) #.sort_by{|invoice| invoice.outstanding }
      else
        company.invoices.includes(:account).where("due_date <= ?", Time.zone.now.to_date)
      .by_status(0).by_branch_id(user.branch_id).order("total_amount DESC, due_date ASC").limit(5) #.sort_by{|invoice| invoice.outstanding }
      end
    end

    def this_month_paybles(company,year, user)
      company.invoices.by_date(year).by_date_range(Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date.end_of_month).by_status(0).by_branch_id(user.branch_id)
    end

    def this_week_paybles(company,year, user)
      company.invoices.by_date(year).by_date_range(Time.zone.now.to_date, Time.zone.now.to_date.end_of_week).by_status(0).by_branch_id(user.branch_id)
    end

    def get_status_id(index)
      string = index
      if /unpaid|Unpaid/i.match(string)
        value = "Unpaid"
      elsif /paid|Paid/i.match(string)
        value = "Paid"
      else
        value = "Draft"
      end
      STATUS.index(value.to_s)
    end

    def invoices_for_customer_as_of_date(company, customer, start_date, end_date)
      start_date = start_date.to_date
      end_date = end_date.blank? ? Time.zone.now.end_of_month.to_date : end_date.to_date
      invoices = company.invoices.by_customer(customer).by_invoice_date_range(start_date, end_date).order("invoice_date DESC")
    end

    def unpaid_invoice_amount_for_customer_as_on_date(company, customer, start_date, end_date)
      invoices = invoices_for_customer_as_of_date(company, customer, start_date, end_date)
      invoices.by_status(0)
      amount = 0
      invoices.each do |invoice|
        amount += invoice.foreign_currency? ? invoice.balance_due*invoice.exchange_rate : invoice.balance_due
      end
      amount
    end

    def yearly_income(company, financial_year, user)
      amount_arr=[]
      month_begin = financial_year.start_date
      while month_begin <= Time.zone.now.beginning_of_month.to_date
        invoices = company.invoices.where(:invoice_date => month_begin..month_begin.end_of_month).by_branch_id(user.branch_id)
        amount_arr<<invoices.sum(:total_amount)
        month_begin = month_begin + 1.month
      end
      amount_arr
    end

    def sold_stock_valuation(invoices, product)
      value=0
      invoices.each do |invoice|
        value+= invoice.invoice_line_items.where(:product_id=>product.id).sum(:amount)
      end
      value
    end

    def new_recursive_invoice(invoice, view_context, financial_year)
      result = false
      transaction do
        year = invoice.company.get_current_financial_year
        due = (invoice.due_date.to_date - invoice.invoice_date.to_date).to_i
        new_invoice = Invoice.new()
        new_invoice.invoice_number = invoice.company.invoice_setting.invoice_number
        new_invoice.company_id = invoice.company_id
        new_invoice.account_id = invoice.account_id
        new_invoice.created_by = invoice.created_by
        new_invoice.currency_id = invoice.currency_id
        new_invoice.financial_year_id=financial_year.id
        new_invoice.exchange_rate = invoice.exchange_rate
        new_invoice.invoice_date = Time.zone.now.to_date
        new_invoice.due_date = Time.zone.now.to_date + due.days
        new_invoice.po_reference = invoice.po_reference
        new_invoice.customer_notes = invoice.customer_notes
        new_invoice.terms_and_conditions = invoice.terms_and_conditions
        new_invoice.invoice_status_id = invoice.invoice_status_id
        new_invoice.cash_customer_name = invoice.cash_customer_name
        new_invoice.cash_customer_mobile = invoice.cash_customer_mobile
        new_invoice.cash_customer_email = invoice.cash_customer_email
        new_invoice.project_id = invoice.project_id
        new_invoice.custom_field1 = invoice.custom_field1
        new_invoice.custom_field2 = invoice.custom_field2
        new_invoice.custom_field3 = invoice.custom_field3
        new_invoice.branch_id = invoice.branch_id
        new_invoice.time_invoice = invoice.time_invoice
        new_invoice.recursive_invoice = 2
        new_invoice.total_amount=invoice.total_amount
        new_invoice.fin_year = year.name
        invoice.invoice_line_items.each do |line_item|
          invoice_line_item = InvoiceLineItem.new()
          invoice_line_item.account_id = line_item.account_id
          invoice_line_item.quantity = line_item.quantity
          invoice_line_item.unit_rate = line_item.unit_rate
          invoice_line_item.discount_percent = line_item.discount_percent
          invoice_line_item.amount = line_item.amount
          invoice_line_item.description = line_item.description
          invoice_line_item.product_id = line_item.product_id
          invoice_line_item.task_id = line_item.task_id
          invoice_line_item.tax = line_item.tax
          invoice_line_item.tax_account_id = line_item.tax_account_id
          invoice_line_item.type = line_item.type
          line_item.sales_warehouse_details.each do |swd|
            sales_warehouse_detail = SalesWarehouseDetail.new(:warehouse_id => swd.warehouse_id,
              :quantity => swd.quantity, :product_batch_id=>swd.product_batch_id, :product_id=>line_item.product_id)
            invoice_line_item.sales_warehouse_details << sales_warehouse_detail
          end
          line_item.tax_accounts.each do |account|
            invoice_line_item.invoice_taxes<<InvoiceTax.new(:account_id=>account.id)
          end
          new_invoice.invoice_line_items << invoice_line_item
        end
        invoice.time_line_items.each do |line_item|
          time_line_item=TimeLineItem.new()
          time_line_item.quantity=line_item.quantity
          time_line_item.unit_rate=line_item.unit_rate
          time_line_item.discount_percent=line_item.discount_percent
          time_line_item.amount=line_item.amount
          time_line_item.description=line_item.description
          time_line_item.tax_account_id=line_item.tax_account_id
          time_line_item.task_id=line_item.task_id
          new_invoice.time_line_items<<time_line_item
        end
        invoice.shipping_line_items.each do |line_item|
          shipping_line_item = ShippingLineItem.new()
          shipping_line_item.account_id=line_item.account_id
          shipping_line_item.amount=line_item.amount
          new_invoice.shipping_line_items<<shipping_line_item
        end
        new_invoice.build_tax
        if invoice.time_invoice?
          if new_invoice.save_with_ledgers
            invoice.recursion.recursive_invoices << RecursiveInvoice.new(:invoice_id => new_invoice.id)
          end
        elsif invoice.stock_available?
          if new_invoice.save_with_ledgers
            customer = invoice.get_party
            invoice.recursion.recursive_invoices << RecursiveInvoice.new(:invoice_id => new_invoice.id)
            if invoice.company.plan.is_inventoriable?
              new_invoice.invoice_line_items.each do |line_item|
                if line_item.inventoriable?
                  product = line_item.product
                  line_item.sales_warehouse_details.each do |warehouse|
                    Stock.reduce(invoice.company.id, product.id, warehouse.warehouse_id, warehouse.quantity)
                  end
                end
              end
            end
            utl_rec = invoice.recursion.utilized_iteration.blank? ? 1 : (invoice.recursion.utilized_iteration + 1)
            invoice.recursion.utilized_iteration = utl_rec
            invoice.save(:validate => false)
            #new_invoice.send_to_both_parties(invoice, view_context)
          end
        else
          new_invoice.invoice_status_id = 1
          utl_rec = invoice.recursion.utilized_iteration.blank? ? 1 : (invoice.recursion.utilized_iteration + 1)
          invoice.recursion.utilized_iteration = utl_rec
          invoice.save(:validate => false)
          new_invoice.save(:validate => false)
          invoice.recursion.recursive_invoices << RecursiveInvoice.new(:invoice_id => new_invoice.id)
          text = "A new invoice has been created with below mentioned details. Its been saved as draft due to insufficient stock and was not sent to the customer. Please review and update with appropriate inventory.<br />"
          text += "<b>Invoice Details</b><br />----------------------<br /><br />"
          text += "Invoice number:#{new_invoice.invoice_number}<br />For Customer:#{invoice.account.name}<br />Amount:#{invoice.amount}<br />Date:#{Time.zone.now.to_date}"
          #invoice.email_recursive_invoice(text.html_safe, view_context ,invoice.company.users.first.email, invoice.company.users.first.first_name, 'Pending invoice') unless invoice.company.users.first.email.blank?
        end
        result = true
        end
      result
    end

    def get_record_with_custom_field(params, company, current_financial_year)
      start_date = params[:start_date].blank? ? current_financial_year.start_date : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      voucher_type = params[:voucher_type]
      val = params[:custom_field] unless params[:custom_field].blank?
      invoice = Invoice.where(:company_id => company.id ,:invoice_date=> start_date..end_date).by_custom_field(val)
    end

    def new_invoice(company, user, financial_year, remote_ip, params)
      invoice= Invoice.new(params[:invoice])
      invoice.company_id = company.id
      invoice.created_by = user.id
      if company.currency_code == 'INR'
        invoice.gst_invoice = true
      end
      invoice.financial_year_id = financial_year.id
      invoice.cash_invoice = true if params[:cash_invoice].present?
      invoice.time_invoice = true if params[:time_invoice].present?
      invoice.invoice_status_id = INVOICE_STATUS[:draft]
      invoice.invoice_number = company.invoice_setting.invoice_number
      unless params[:account_id].blank?
        invoice.account_id = params[:account_id]
        invoice.billing_address=Address.new(invoice.get_party.billing_address.attributes) unless invoice.get_party.blank? || invoice.get_party.billing_address.blank?
        invoice.shipping_address=Address.new(invoice.get_party.shipping_address.attributes) unless invoice.get_party.blank? || invoice.get_party.shipping_address.blank?
      end
      invoice.project_id=params[:project_id] if params[:project_id].present?
      invoice.customer_notes = company.customer_note
      invoice.terms_and_conditions = company.terms_and_conditions
      invoice.invoice_date = Time.zone.now.to_date
      invoice.due_date = (params[:cash_invoice] ? Time.zone.now.to_date : Time.zone.now.to_date.advance(:weeks =>1))
      invoice.invoice_line_items.build if invoice.cash_invoice? || !invoice.time_invoice?
      invoice.time_line_items.build if invoice.time_invoice?
      unless invoice.cash_invoice?
        invoice.build_recursion
        invoice.recursion.schedule_on = Time.zone.now.to_date
        invoice.recursion.company_id=company.id
      end
      invoice.save!(:validate=>false)
      invoice.register_user_action(remote_ip, 'created')
      invoice
    end

    def create_invoice(params, company, user, fyr)
      invoice = Invoice.new(params[:invoice])
      invoice.company_id = company
      invoice.created_by = user.id
      invoice.project_id = Project.get_project_id(params[:project_id], company)
      invoice.branch_id = user.branch_id unless user.branch_id.blank?
      invoice.currency_id = invoice.account.get_currency_id unless invoice.account.blank? || invoice.cash_invoice?
      if invoice.currency_id.blank? || invoice.account.get_currency == invoice.company.currency_code
        invoice.exchange_rate = 0
      end
      invoice.fin_year = fyr
      invoice.build_tax
      invoice_total=0
      if invoice.time_invoice?
        invoice.time_line_items.each do |line_item|
          invoice_total += line_item.amount
        end
      else
        invoice.invoice_line_items.each do |line_item|
          invoice_total += line_item.amount
        end
      end

      tax_total=0
      invoice.tax_line_items.each do |line_item|
        tax_total += line_item.amount
      end

      ship_charge=0
      invoice.shipping_line_items.each do |line_item|
        ship_charge += line_item.amount
      end

      total = invoice_total + ship_charge + ( !invoice.tax_inclusive? ? tax_total : 0 )
      invoice.total_amount=total

      invoice
    end

    def update_invoice(params, company, user, fyr)
      invoice = Invoice.find(params[:id])
      invoice.assign_attributes(params[:invoice])
      if invoice.account.blank?
        invoice.account_id=nil 
        invoice.customer_id=nil
      else
        if !invoice.cash_invoice?
          if invoice.account.customer.present?
            invoice.customer_id = invoice.account.customer.id
          elsif invoice.account.vendor.present?
            invoice.vendor_id = invoice.account.vendor.id
          end
        end     
      end  
      invoice.invoice_status_id=0 unless params[:draft].present? || invoice.cash_invoice?
      invoice.invoice_status_id=2 if !params[:draft].present? && invoice.cash_invoice?
      # invoice.project_id = Project.get_project_id(params[:project_id], company)
      invoice.branch_id = user.branch_id unless user.branch_id.blank?
      invoice.currency_id = invoice.account.get_currency_id unless invoice.account.blank? || invoice.cash_invoice?

      #set default fields if not already set
      if invoice.currency_id.blank?
        invoice.currency_id = (Currency.find_by_currency_code(company.currency_code)).id
        invoice.exchange_rate = 1
      end
      invoice.fin_year = fyr
      if invoice.original_invoice.draft? && invoice.recursive_enabled? && params[:recursive] == '1'
        invoice.recursive_invoice = 1
      elsif !invoice.draft? && !invoice.recursion.blank? && params[:recursive] == '0'
        invoice.recursive_invoice=0
        invoice.recursion.delete
      end
      invoice
    end

    def get_template(company, voucher_type, dlc)
      if dlc == "yes"
        template_name = "delivery_challan.pdf.prawn"
      else
        company_template = CompanyTemplate.find_by_company_id_and_voucher_type(company.id, voucher_type)
        if !company_template.blank?
          template = Template.find_by_id_and_voucher_type(company_template.template_id, company_template.voucher_type)
        end
        template_name = template.template_name
      end
    end
  end # end self methods

  def calculate_total_amount
    invoice_total =0
    if time_invoice?
      time_line_items.each do |line_item|
        invoice_total += line_item.amount
      end
    else
      invoice_line_items.each do |line_item|
        invoice_total += line_item.amount
      end
    end

    tax_total=0
    tax_line_items.each do |line_item|
      tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
      tax_total += line_item.amount
    end

    ship_charge=0
    shipping_line_items.each do |line_item|
      ship_charge += line_item.amount
    end
    total = invoice_total + ship_charge + ( !tax_inclusive? ? tax_total : 0 )
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
      " #{invoice_number} for customer #{customer_name} for amount #{total_amount}", action, branch_id)
  end

    def register_link_action(remote_ip,user,action)
    Workstream.register_user_action(company_id, user, remote_ip,
      " #{invoice_number} for customer #{customer_name} for amount #{outstanding}", action, branch_id)
  end

  def register_delete_action(remote_ip,user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
      " #{invoice_number} for customer #{customer_name} for amount #{total_amount}", action, branch_id)
  end

  def create_invoice_history(invoice,company,user,action)
    invoice_history = InvoiceHistory.new
    invoice_history.invoice_id = invoice
    invoice_history.company_id = company
    invoice_history.description = action
    invoice_history.created_by = user
    invoice_history.record_date = Time.zone.now
    invoice_history.save
  end

  def update_inventory
    # This method will refresh the inventory after after invoice update(By Manjeet)
    invoice_line_items.each do |line_item|
      if !line_item.marked_for_destruction? && line_item.inventoriable? && company.plan.is_inventoriable?
        line_item.reallocate_inventory
      end
    end
  end

  def keep_back_inventory
    # This method will delete the sales_warehouse_details and retain the inventory back to respective warehouse(By Manjeet)
    #invoice = Invoice.find id
    invoice_line_items.each do |invoice_line_item|
      line_item = InvoiceLineItem.find_by_id invoice_line_item.id
      unless line_item.blank? || invoice_line_item.marked_for_destruction?
        if self.draft?
          # in case draft invoice, details will be deleted, no iventory get affected.
          SalesWarehouseDetail.delete(line_item.sales_warehouse_details)
        elsif !line_item.product.blank? && line_item.inventoriable? && company.plan.is_inventoriable?
          line_item.sales_warehouse_details.each do |swd|
            swd.destroy
          end
        end
      end
    end
  end

  def invoice_date_and_due_date
    if !(due_date.nil? || invoice_date.nil?) && due_date < invoice_date
      errors.add(:due_date, " should be greater than or equal to invoice date" )
    end
  end

  def total_quantity
    qty_total = self.time_invoice? ? self.time_line_items.sum(:quantity) : self.invoice_line_items.sum(:quantity)
    qty_total
  end

  def received_amt
    self.invoices_receipts.where(:deleted => false).sum(:amount)
  end

  def tds_amt
    tds_amt =  invoices_receipts.sum('tds_amount')
  end

  def total_received_amt
    if gst_invoice?
      paid_amount + allocated_gst_credit + allocated_credit + total_returned
    else
      paid_amount + allocated_credit + total_returned
    end
  end

   # Exchange currency issue purpose
   # Date 26-09-2016
   # Author: Ashish Shal

   def return_substracted_outstanding
    if gst_invoice?
     total_amount - (paid_amount + total_returned + allocated_gst_credit + allocated_credit) 
   else
     total_amount - (paid_amount + total_returned + allocated_credit)
   end
 end

  # def outstanding
  #   amount=return_substracted_outstanding
  #   amount<0? 0 : amount
  # end

  def outstanding_report
    amount=return_substracted_outstanding_report
    amount<0? 0 : amount
  end



  def allocated_credit
    invoice_credit_allocations.sum(:amount)
  end

  def total_returned
    invoice_returns.sum(:total_amount)
  end

  def gain_or_loss
    expected_amount=total_amount*exchange_rate
    received_amount=0
    invoices_receipts.each do |invoice_receipt|
      received_amount+=invoice_receipt.amount*invoice_receipt.receipt_voucher.exchange_rate
    end
    ((expected_amount-received_amount)/exchange_rate).round(2)
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


     

  def group_tax_amt(account_id)
    amt = 0
    tax_items = self.tax_line_items.where(:account_id => account_id)
    tax_items.each do |item|
      amt += item.amount
    end
    amt
  end

  def sub_total
    self.time_invoice? ? self.time_line_items.sum(:amount) : self.invoice_line_items.sum(:amount)
  end

  def ship_charge
    self.shipping_line_items.sum(:amount)
  end

  # TODO: discount is calculated in multiple method with separate way. Keep simgle method to calculate discoutn
  def discount
    amount = 0
    discount = 0
    total_discount = 0
    line_items = self.time_invoice? ? time_line_items : invoice_line_items
    line_items.each do |line_item|
      unless line_item.tax? || line_item.unit_rate.blank? || line_item.quantity.blank? || line_item.discount_percent.blank?
        amount = (line_item.quantity*line_item.unit_rate)
        discount = amount*(line_item.discount_percent/100)
        total_discount += discount
      end
    end
    total_discount
  end

  def mark_return_status
    self.update_attribute(:invoice_status_id, INVOICE_STATUS[:returned])
  end

  # action to update invoice status as per payment
  def update_invoice_status
    if outstanding>0
      self.update_attribute(:invoice_status_id, 0)
    else
      self.update_attribute(:invoice_status_id, 2)
    end
  end
  def update_invoice_online_status
      self.update_attribute(:invoice_status_id, 2)
  end

  def invoice_status_name
    invoice_status.status if invoice_status
  end

  def customer_name
    if cash_invoice?
      ( !cash_customer_name.blank? ? cash_customer_name : "Not available")
    elsif customer.present?   
      customer.name
    elsif vendor.present?
      vendor.name
    else
      self.account.name  unless self.account.blank?  
    end
  end

  def customer_GSTIN
    gstin = nil
    if cash_invoice?
      gstin = cash_customer_gstin
    elsif customer.present?   
      gstin = customer.GSTIN
    elsif vendor.present?
      gstin = vendor.GSTIN
    end
    gstin
  end

  def email
    if cash_invoice?
      cash_customer_email if !cash_customer_email.blank?
    elsif customer.present?
      customer.email
    elsif vendor.present?
      vendor.email
    else
      ""  
    end
  end

  def invoice_title
    voucher_title_id.blank? ? "Invoice" : VoucherTitle.find(voucher_title_id).voucher_title
  end

  def save_with_ledgers
    save_result = false
    transaction do
      if save
        invoice_line_items.each do |line_item|

          credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
          random_str=Ledger.generate_secure_random

          debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, invoice_date,
            line_item.amount_with_exchange_rate, invoice_number, created_by, line_item.description, branch_id, random_str, credit_account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(credit_account_id, company_id, invoice_date,
            line_item.amount_with_exchange_rate, invoice_number, created_by, line_item.description, branch_id, random_str, account_id)

          #build and save relationship between invoice and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
          if !line_item.discount_percent.blank? && line_item.discount_percent>0.0
            discount_account=Account.find_by_name_and_accountable_type_and_company_id("Discount on Sales Account", "IndirectExpenseAccount", company_id)
            random_str=Ledger.generate_secure_random
            debit_ledger_entry = Ledger.new_debit_ledger(discount_account.id, company_id, invoice_date,
              line_item.discount_amount, invoice_number, created_by, line_item.description, branch_id, random_str, account_id)

            # credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
            credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, invoice_date,
              line_item.discount_amount, invoice_number, created_by, line_item.description, branch_id, random_str, discount_account.id)
            ledgers << debit_ledger_entry
            ledgers << credit_ledger_entry
          end
        end

        tax_line_items.each do |line_item|
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, invoice_date,
            line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, line_item.account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(line_item.account_id, company_id, invoice_date,
            line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str,account_id)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end

        time_line_items.each do |line_item|
          random_str=Ledger.generate_secure_random
          time_account_id = Task.find(line_item.task_id).sales_account_id
          debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, invoice_date,
            line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, time_account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(time_account_id, company_id, invoice_date,
            line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, account_id)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end

        shipping_line_items.each do |line_item|
          debit_account= line_item.amount<0 ? line_item.account_id : account_id
          credit_account= line_item.amount<0 ? account_id : line_item.account_id
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(debit_account, company_id, invoice_date,
            line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, credit_account)

          credit_ledger_entry = Ledger.new_credit_ledger(credit_account, company_id, invoice_date,
            line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, debit_account)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
        save_result = true
      end
    end
    save_result
  end

  #method for updating invoice with ledger
  def update_and_post_ledgers
    update_result = false
    transaction do
      Ledger.delete(ledgers)
      InvoiceLineItem.delete(tax_line_items)
      invoice_line_items.reload
      invoice_line_items.each do |line_item|
        random_str=Ledger.generate_secure_random
        credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
        debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, invoice_date,
          line_item.amount_with_exchange_rate, invoice_number, created_by, line_item.description, branch_id, random_str, credit_account_id)
        credit_ledger_entry = Ledger.new_credit_ledger(credit_account_id, company_id, invoice_date,
          line_item.amount_with_exchange_rate, invoice_number, created_by, line_item.description, branch_id, random_str, account_id)

        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
        if line_item.discount_percent.present? && line_item.discount_percent>0.0
          discount_account=Account.find_by_name_and_accountable_type_and_company_id("Discount on Sales Account", "IndirectExpenseAccount", company_id)
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(discount_account.id, company_id, invoice_date,
            line_item.discount_amount, invoice_number, created_by, line_item.description, branch_id, random_str, account_id)

          # credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, invoice_date,
            line_item.discount_amount, invoice_number, created_by, line_item.description, branch_id, random_str, discount_account.id)
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
      end

      build_tax
      tax_line_items.reload
      tax_line_items.each do |line_item|
        #write code to allow entry if gst invoice and parent id present
        tax_account = line_item.account
        next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, invoice_date,
          line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, line_item.account_id)
        credit_ledger_entry = Ledger.new_credit_ledger(line_item.account_id, company_id, invoice_date,
          line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, account_id)

        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
      end

      time_line_items.reload
      time_line_items.each do |line_item|
        random_str=Ledger.generate_secure_random
        time_account_id = Task.find(line_item.task_id).sales_account_id

        debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, invoice_date,
          line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, time_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(time_account_id, company_id, invoice_date,
          line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, account_id)

        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
      end

      shipping_line_items.reload
      shipping_line_items.each do |line_item|
        debit_account= line_item.amount<0 ? line_item.account_id : account_id
        credit_account= line_item.amount<0 ? account_id : line_item.account_id

        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(debit_account, company_id, invoice_date,
          line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, credit_account)

        credit_ledger_entry = Ledger.new_credit_ledger(credit_account, company_id, invoice_date,
          line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, debit_account)
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
      end
      update_result = true
    end
    update_attribute("total_amount", calculate_total_amount)
    update_result
  end


  #soft delete method
  def delete
    transaction do
      if paid_amount > 0
        save_received_amount_as_advance
        update_exist_receipts_with_ledger
      end
      
      if gst_invoice && !draft?
        GstInvoiceDeleteWorker.perform_async(company_id, id, invoice_date.strftime("%Y%m%d"))
      end
      if draft?
        logger.debug "========Invoice::delete::  deleting draft invoice #{invoice_status_id}"
        destroy
      end
      destroy
      # sales_orders.first.update_billing_status unless sales_orders.blank?
    end
  end
  #restore method
  # def restore(restored_by_user)
  #   result = false
  #   transaction do
  #     if update_attributes(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
  #       ledgers.update_all(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
  #       receipt_vouchers.each do |rv|
  #         rv.fin_year = fin_year
  #         rv.restore(restored_by_user)
  #       end
  #       result = true
  #     end
  #   end
  # end

  def project_name
    project_id.blank? ? "Not available" : Project.find(project_id).name
  end

  def get_status
    STATUS[invoice_status_id.to_s]
  end

  def created_by_user
    user.full_name
  end

end
