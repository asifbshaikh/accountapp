class ReceiptAdvance < ActiveRecord::Base

  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:received_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:from_account_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:received_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  #scope :by_project, lambda{|project| where(:project_id=>project) unless project.blank? }
  scope :by_advance, lambda { |is_advance| is_advance.blank? ? where(:advanced=>false) : where(:advanced=>true) }
  scope :not_in, lambda { |id| where("id not in(?)",id.map { |e| e.id }) unless id.blank?}





  belongs_to :company
   belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  
  belongs_to :user, :foreign_key=> :created_by
  belongs_to :receipt
  belongs_to :product
  belongs_to :account
  belongs_to :company
  belongs_to :currency
  belongs_to :purchase
  belongs_to :gstr_advance_receipt



  has_many :gstr_advance_receipt_invoices, :conditions => {:deleted => false}
  has_many :invoices, :through => :gstr_advance_receipt_invoices, :dependent=> :destroy	

   attr_accessible :receipt_id, :company_id,:gstr_advance_receipt_id, :status, :amount, :from_account_id, :to_account_id, :voucher_number,
                   :voucher_date, :project_id, :currency_id, :exchange_rate, :received_date    

  validates_associated :payment_detail
  validates_presence_of  :voucher_number, :voucher_date, :received_date, :amount, :to_account_id, :from_account_id

  validate :validate_from_account_type, :if => :from_account_id
  validate :validate_to_account_type, :if => :to_account_id


  attr_accessor :fin_year




















def get_party
    logger.debug "hello"
    logger.debug account.inspect
    account.customer.blank? ? account.vendor : account.customer
  end




	
end
