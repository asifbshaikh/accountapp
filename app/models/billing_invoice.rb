class BillingInvoice < ActiveRecord::Base
  has_one :payment_transaction
  has_many :billing_line_items
  belongs_to :company
  has_one :payment_detail, :as => :voucher, :dependent => :destroy

  validates_presence_of :billing_line_items
  validates :amount, :numericality => {:greater_than => 0}

  def mark_paid
    update_attribute(:status_id, 1)
  end

  def status
  	if status_id == 1
  		"Success"
  	else
  		"Fail"
  	end
  end

  def self.get_sales_by_user(params)
    start_date = params[:start_date].blank? ? Time.zone.now.to_date : params[:start_date].to_date
    end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    if !params[:super_user].blank?
      @sales_by_user = self.where("invoice_date BETWEEN ? AND ? and closed_by = ?", start_date.to_date, end_date.to_date,params[:super_user]).order("invoice_date DESC")
    else
      @sales_by_user = self.where("invoice_date BETWEEN ? AND ? and closed_by = ?", start_date.to_date, end_date.to_date,SuperUser.first).group(:company_id).order("invoice_date DESC")
    end
    @sales_by_user
  end
end
