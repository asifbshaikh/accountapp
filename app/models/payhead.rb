class Payhead < ActiveRecord::Base
  scope :exclude_taken, lambda { |st| where("optional=false and id not in (?)", st.salary_structure_line_items.map {|a| a.payhead_id })}

  #relationship
  has_many :salaries
  has_many :salary_structure_line_items
  has_many :salary_structure_history_line_items
  belongs_to :user
  belongs_to :company
  has_many :variable_payhead_details
  # belongs_to :salary_structure_line_items

  #validations
  validates_presence_of :payhead_name, :payhead_type,  :affect_net_salary, :name_appear_in_payslip, :account_id
  validates_uniqueness_of :payhead_name, :scope => :company_id

  CALC_TYPE = {:fixed => 1, :percent => 2}

  def salary_breakage(user, date)
    Salaries.where(:payhead_id=>id, :user_id=>user, :company_id=>company_id, :month=>date.beginning_of_month..date.end_of_month).first
  end

  def variable_payhead_for_this_month(month, user)
    unless month.blank?
      @variable_payhead = VariablePayheadDetail.where(:company_id=>company_id, :user_id=>user, :payhead_id=>id, :month=>month.beginning_of_month..month.end_of_month).first
    end
    @variable_payhead
  end

  #method for payhead creation on new signup
  def self.create_default_payheads(company_id, user_id)
    payhead_names = ["Basic","House Rent Allowance","Dearness Allowance", "Travelling Allowance","Bonus"]
    payhead_names.each do |name|
      account = Account.find_by_company_id_and_name(company_id, name)
      payhead = Payhead.new
      payhead.payhead_name = name
      payhead.company_id = company_id
      payhead.defined_by = user_id
      payhead.payhead_type = "Earnings"
      payhead.affect_net_salary = "Yes"
      payhead.use_of_gratuity = "No"
      payhead.calculation_type = 2
      payhead.name_appear_in_payslip = name
      payhead.optional = (payhead.payhead_name == "Bonus" ? true : false)
      payhead.account_id = account.id
      payhead.save!
    end
  end

  def fixed?
    CALC_TYPE[:fixed] == self.calculation_type
  end


  def get_visibility
    if optional==true
      "Optional"
    else
      "Mandatory"
    end
  end

  def account_name
    account = Account.find_by_id(account_id)
    account.name unless account.blank?
  end

  def register_user_action(remote_ip, action, branch_id)
    Workstream.register_user_action(company_id, defined_by, remote_ip,
      "Payhead #{payhead_name} and it's a #{payhead_type} payhead is #{action}", action, branch_id)
  end

  def has_records?
    !salaries.blank? || !salary_structure_line_items.blank? || !salary_structure_history_line_items.blank? || !variable_payhead_details.blank?
  end

end
