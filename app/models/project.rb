class Project < ActiveRecord::Base

  #ASSOCIATIONS
  belongs_to :company
  belongs_to :user
  has_many :invoices
  has_many :expenses
  has_many :receipt_vouchers
  has_many :purchases
  has_many :purchase_orders
  has_many :sales_orders
  has_many :tasks
  has_many :journals

  #NAMED_SCOPES
  scope :active, lambda { where(:status => false) }

  #VALIDATIONS
  validates_presence_of :company_id, :created_by, :start_date, :name
  validates_uniqueness_of :name, :scope => :company_id
  validates :description, :length => { :maximum => 200 }
  validates :estimated_cost, :numericality => {:greater_than_or_equal_to => 0.00,
    :message => " should not be negative." }

  attr_accessor :fin_year

  class << self

    def get_project_ids(company,project)
      projects = Project.where("company_id = ? and name like ?",company, project)
      @project_ids = []
      if !projects.blank?
        projects.each do |p|
          @project_ids << p.id
        end
      end
      @project_ids
    end

    def company_projects(company)
      projects = Project.where(company_id: company)
      arr=[]
      projects.each do |project|
        hash={}
        hash["id"]=project.id
        hash["name"]=project.name
        arr<<hash
      end
      arr.to_json
    end

    def get_project_id(name, company)
      project = Project.find_by_name_and_company_id(name, company)
      if project.blank?
        nil
      else
        project.id
      end
    end

    def create_project(params,company, user,fyr)
      project = Project.new(params[:project])
      project.company_id = company
      project.created_by = user.id
      project.fin_year = fyr
      project
    end

    def update_project(params, company, user, fyr)
      project = Project.find(params[:id])
      project.fin_year = fyr
      project
    end

  end

  #Returns the total amount of invoices generated for this project
  def invoices_total
    invoice_amount=self.invoices.sum(:total_amount)
    return_invoice_amount=InvoiceReturn.where(:company_id=>self.company_id).includes(:invoice).where(:invoices=>{:project_id=>self.id}).sum(:total_amount)
    invoice_amount - return_invoice_amount
  end

  #Returns the total amount of expenses generated for this project
  def expenses_total
    self.expenses.sum(:total_amount)
  end

  #Returns the total amount of receipts generated for this project
  def receipts_total
    self.receipt_vouchers.sum(:amount)
  end

  #Returns the total amount of purchases generated for this project
  def purchases_total
    purchase_amount = self.purchases.sum(:total_amount)
    return_purchase_amount = PurchaseReturn.where(:company_id=>company_id).includes(:purchase).where(:purchases=>{:project_id=>self.id}).sum(:total_amount)
    purchase_amount - return_purchase_amount
  end

  def created_by_user
    User.find(created_by).full_name
  end

  def closed_by_user
    User.find(closed_by).full_name
  end

  def get_status
    if status == false
      "Ongoing"
    else
      "Complete"
    end
  end

  def completed?
    status
  end

  #method to mark the project complete
  def complete_project(closed_by_user)
    result = false
    transaction do
      if update_attributes(:closed_by => closed_by_user.id, :status => true, :end_date => Time.zone.now.to_date)
        register_user_action(closed_by_user.remote_ip, 'completed', closed_by_user)
        result = true
      end
    end
    result
  end

  def total_invoice_amount
    invoices = self.invoices.where(:deleted => false ).sum(:total_amount)
  end

  def total_received_amount
    total = 0
    receipt_vouchers = self.receipt_vouchers.where(:deleted => false )
    receipt_vouchers.each do |receipt_voucher|
      total += receipt_voucher.amount
    end
    total
  end

  def total_expense_amount
    total = 0
    expenses = self.expenses.where(:deleted => false )
    expenses.each do |expense|
      total += expense.amount
    end
    total
  end

  def total_purchase_amount
    total = 0
    purchase = self.purchases.where(:deleted => false)
    purchases.each do |purchase|
      total += purchase.amount
    end
    total
  end

  #workstream saving code created here
  def register_user_action(remote_ip, action, user)
    Workstream.register_user_action(company_id, user.id, remote_ip, "Project #{name}", action, branch_id)
  end

end
