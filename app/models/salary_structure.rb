class SalaryStructure < ActiveRecord::Base

  has_many :salary_structure_line_items, :dependent => :destroy, :include => :payhead
  has_many :salary_structure_histories, :dependent => :destroy
  belongs_to :user

  accepts_nested_attributes_for :salary_structure_line_items, :reject_if => lambda {|p| p[:payhead_id].blank? || (!p[:amount].blank? && p[:amount].to_f<=0.0) }, :allow_destroy => true
  # attr_accessible :salary_structure_line_items_attributes
  #validation

  validates_presence_of :effective_from_date, :for_employee
  validates_presence_of :salary_structure_line_items
  validates_associated :salary_structure_line_items
  validate :duration_between_two_effective_from_date, :on => :create
  validate :effective_date_should_be_greater_joining_date, :on =>:create

  # attr_accessor :joining_date

  # validate :effective_date_should_not_less_than_today, :on => :create
  # before_save :check_destruction_if_needed

  # def check_destruction_if_needed
  #   salary_structure_line_items.each do |line_item|
  #     line_item.mark_for_destruction if line_item.payhead_id.blank? || (!line_item.amount.blank? && line_item.amount.to_f==0.0)
  #   end
  # end

  def get_line_item(payhead)
    SalaryStructureLineItem.where(:payhead_id=>payhead.id, :salary_structure_id=>id).first
  end

  # def effective_date_should_not_less_than_today
  #   if !effective_from_date.blank? && effective_from_date < Time.zone.now.to_date
  #     errors.add(:effective_from_date, " must not be less than today.")
  #   end
  # end

  def effective_date_should_be_greater_joining_date
    user_details = UserSalaryDetail.find_by_user_id(for_employee)
    
    if user_details.blank?
      errors.add(:effective_from_date, "Please update joining date in user information. It's mandatory to provide joining data before configuring salary detail.")
    else !user_details.date_of_joining.blank?
      if !effective_from_date.blank? && effective_from_date < user_details.date_of_joining
        errors.add(:effective_from_date, " must not be less than joining date.")
      end
    end
  end


  def duration_between_two_effective_from_date
    last_salary_structure = SalaryStructure.order("effective_from_date DESC").where("effective_from_date < ?  and company_id=? and for_employee=?", effective_from_date, company_id, for_employee).first unless effective_from_date.blank?
    unless last_salary_structure.blank?
      if !effective_from_date.blank? && last_salary_structure.effective_from_date > (effective_from_date - 1.months)
        errors.add(:base, "Salary structure already defined for this duration.")
      end
    end
  end

  def for_employee_name
   User.find(for_employee).full_name
  end

  def total_amount
    total = 0
    self.salary_structure_line_items.each do |line_item|
        amount =  line_item.amount
       payhead_type = line_item.payhead.payhead_type
      if payhead_type == 'Earnings'
        total = total+amount
      else
         total = total-amount
      end
    end
    total
  end

  def save_with_variable_payheads
     save_result = false
     transaction do
     var_payheads = Payhead.where(:company_id => company_id, :optional => true)
     save
     if !var_payheads.blank?
      for var_payhead in var_payheads
        salary_structure_line_item = SalaryStructureLineItem.find_by_payhead_id_and_salary_structure_id(var_payhead.id, self.id)
       if salary_structure_line_item.blank?
        salary_structure_line_item = SalaryStructureLineItem.new
        salary_structure_line_item.salary_structure_id = self.id
        salary_structure_line_item.payhead_id = var_payhead.id
        salary_structure_line_item.amount = 0
        salary_structure_line_item.save
       end
       end
    end
          save_result = true
     end
      save_result
  end

 # creating salary structure history on update of salary structure
 def create_history(salary_structure, user)
    save_result = false
    transaction do
    @salary_structure_history = SalaryStructureHistory.new
    @salary_structure_history.salary_structure_id = salary_structure.id
    @salary_structure_history.company_id = salary_structure.company_id
    @salary_structure_history.created_by = user.id
    @salary_structure_history.for_employee = salary_structure.for_employee
    @salary_structure_history.effective_from_date = salary_structure.effective_from_date
    @salary_structure_history.updated_on_date = Time.zone.now.to_date

    salary_structure.salary_structure_line_items.each do |line_item|
      salary_structure_history_line_item = SalaryStructureHistoryLineItem.new(
       :payhead_id => line_item.payhead_id,
       :amount => line_item.amount
      )
      @salary_structure_history.salary_structure_history_line_items << salary_structure_history_line_item
    end
    @salary_structure_history.save!
     save_result = true
    end
      save_result
  end

  def register_user_action(remote_ip, action, branch_id)
     Workstream.register_user_action(company_id, created_by, remote_ip,
         " Salary structure for #{for_employee_name} #{action} and it is applicable from #{effective_from_date}", action, branch_id)
  end

  class << self
    def current_salary_structure(company, user, month)
      if month.blank?
        month = Time.zone.now.to_date.end_of_month
      else
        year = (month>Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
        month = Date.new(year, month, 1).end_of_month
      end
      salary_structure = SalaryStructure.where("effective_from_date <= ? and (valid_till_date >= ? or valid_till_date is null ) and company_id=? and for_employee=? ", month, month, company, user).first
    end

    def create_salary_structure(salary_structure, company, user)
      #params = params[:salary_structure][:salary_structure_line_items_attributes].delete(:id)
      new_salary_structure = SalaryStructure.new()
      salary_structure.salary_structure_line_items.each do |line_item|
        salary_structure_line_item = SalaryStructureLineItem.new(:payhead_id=> line_item.payhead_id,
          :amount => line_item.amount)
        new_salary_structure.salary_structure_line_items<<salary_structure_line_item
      end
      new_salary_structure.for_employee = salary_structure.for_employee
      new_salary_structure.effective_from_date = salary_structure.effective_from_date
      new_salary_structure.company_id = company
      new_salary_structure.created_by = user
      new_salary_structure
    end

  end
end
