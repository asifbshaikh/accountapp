require 'digest/sha1'
class User < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :with_salary_structure, lambda { joins(:salary_structures).group(:for_employee)}#:joins=>:salary_structures
  scope :by_joining, lambda {|month| joins(:user_salary_detail).where('user_salary_details.date_of_joining < ? and deleted=0', month.end_of_month)}
  scope :by_salary_structure, lambda {|month| joins(:salary_structures).group(:for_employee)}
  scope :this_month_processable, lambda {|month| by_joining(month).by_salary_structure(month)}
  scope :this_month_payroll_participation, lambda {|month| joins(:salaries).where('salaries.month BETWEEN ? AND ?', month, month.end_of_month).group(:user_id)}
  scope :without_salary_structure, lambda { includes(:salary_structures).where('salary_structures.id is null') }

  #  after_save :utilized_storage
  attr_accessor :old_file_size
  attr_accessor :password_confirmation

  before_save :destroy_avatar?

  #relationships
  belongs_to :company
  belongs_to :branch
  belongs_to :designation
  belongs_to :department

  has_one :user_information
  has_one :user_salary_detail
  has_one :user_referral

  has_many  :leave_cards, :dependent => :destroy
  has_many  :projects
  has_many  :client_invitations
  has_many  :variable_payhead_details
  has_many  :attendances
  has_many  :company_assets, :dependent => :destroy
  has_many  :folders, :dependent => :destroy
  has_many  :salaries
  has_many  :tasks
  has_many  :myfiles, :dependent => :destroy
  has_many  :leave_requests
  has_many  :salary_structures, :foreign_key => "for_employee", :dependent => :destroy
  has_many  :employee_goals, :foreign_key => "for_employee"
  has_many  :notes, :foreign_key => "created_by"
  has_many  :policy_documents
  has_many  :usernotes, :dependent => :destroy
  has_many  :assignments
  has_many  :roles, :through => :assignments
  has_many  :invitation_details, :foreign_key => "sent_by"
  has_many  :pbreferrals, :foreign_key => "invited_by"
  has_many  :salary_computation_results
  has_many  :invoices, :foreign_key => :created_by
  has_many  :payment_vouchers, foreign_key: :created_by

  #delegations
  delegate :birthday?, to: :user_information unless :user_information.blank?
  delegate :name, to: :branch, prefix: true, :allow_nil=> true
  delegate :name, to: :company, prefix: true, :allow_nil=> true
  delegate :title, to: :designation, prefix: true, :allow_nil => true
  delegate :emergency_contact, to: :user_information, :allow_nil => true
  delegate :present_address, to: :user_information, :allow_nil => true
  delegate :permanent_address, to: :user_information, :allow_nil => true
  delegate :gender, to: :user_information, :allow_nil => true
  delegate :blood_group, to: :user_information, :allow_nil => true
  delegate :birth_date, to: :user_information, :allow_nil => true
  delegate :date_of_joining, to: :user_salary_detail, :allow_nil => true
  delegate :employee_no, to: :user_salary_detail, :allow_nil => true
  delegate :work_type, to: :user_salary_detail, :allow_nil => true
  delegate :payment_type, to: :user_salary_detail, :allow_nil => true
  delegate :PAN, to: :user_salary_detail, :allow_nil => true
  delegate :PF_account_number, to: :user_salary_detail, :allow_nil => true
  delegate :bank_account_number, to: :user_salary_detail, :allow_nil => true
  delegate :bank_name, to: :user_salary_detail, :allow_nil => true
  delegate :branch, to: :user_salary_detail, prefix: true, :allow_nil => true
  delegate :ifsc_code, to: :user_salary_detail, :allow_nil => true
  delegate :date_of_leaving, to: :user_salary_detail,  :allow_nil => true


  accepts_nested_attributes_for :user_information, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :user_salary_detail, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :usernotes, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :salary_structures, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :assignments
  accepts_nested_attributes_for :variable_payhead_details, :reject_if => lambda {|a| a[:amount].blank? || a[:amount].to_f <= 0.0 }

  attr_accessible :username, :first_name, :last_name,:password, :password_confirmation,:email, :department_id, :designation_id, :branch_id,:prefix,:middle_name,
                  :reset_password, :reporting_to_id, :user_information_attributes, :user_salary_detail_attributes, :salary_structures_attributes,
                  :usernotes_attributes, :last_login_time, :deleted, :deleted_by, :deleted_datetime, :assignments_attributes, :avatar, :delete_avatar, :variable_payhead_details_attributes

  #attr_writer :current_step
  # validate :birth_date_and_marriage_date_and_passport_expiry_date
       # def birth_date_and_marriage_date
           # if (UserInformation.marriage_date < UserInformation.birth_date)||(UserInformation.passport_expiry_date < UserInformation.birth_date)
             # error.add(:birth_date,"should less than or equale to Passport expiry and Marriage date")
           # end
       # end

  #validations
  #Made changes to simplify logon process
  #Removed validation for presence of first name, last name, username & password during creation
  #Author: Ashish Wadekar
  #Date: 19th October 2016

  #validates_presence_of :first_name, :last_name, :email, :username#, :date_of_joining
  validates_presence_of :email
  validates :first_name,:length => { :maximum => 20 }, :on => :update
  validates :last_name,:length => { :maximum => 20 }, :on => :update
  #validates_presence_of :password, :on => :create
  validates_uniqueness_of :username, :message => "has already been taken" #, :scope => :company_id
  validates_uniqueness_of :email, :scope =>:company_id
  #validates_confirmation_of :password, :on => :create
  validate :user_limit , :if => "!company.blank?", :on => :create
  #validate :storage_limit, :if => "!company.blank?"
  #validate :password_non_blank
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :uniqueness => true, :message => "should be a valid format"


 #Code for user avatar validations and size limit
  has_attached_file :avatar,:use_timestamp => false,
                    :styles => {:original => "150X150", :small => "80x80", :thumb => "100x100" },:default_style => :thumb,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:id/:style/:basename.:extension"
  validates_attachment_size :avatar, :less_than => 500.kilobytes, :message => "should less than or equal to 500 KB."
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg','image/png','image /jpg'],
                                    :message=>" must be of .jpeg,'.jpg' or .png type",
                                    :allow_nil => true


  def role_name
    self.roles[0].name
  end

  def branch_name
    branch.name unless branch.nil?
  end

  def get_salary
    Salary.where(:user_id => id)
  end
  def get_bank_account_number
    user_salary_detail.blank? || user_salary_detail.bank_account_number.blank? ? "Not available" : user_salary_detail.bank_account_number
  end

  def get_bank_name
    user_salary_detail.blank? || user_salary_detail.bank_name.blank? ? "Not available" : user_salary_detail.bank_name
  end

  def get_branch
    user_salary_detail.blank? || user_salary_detail.branch.blank? ? "Not available" : user_salary_detail.branch
  end

  def on_branch?
    !branch_id.blank?
  end

  def variable_payhead_for_this_month(month)
    @variable_payheads = variable_payhead_details.where(:month=>month.beginning_of_month..month.end_of_month) unless month.blank?
  end

  def this_month_attendance(month)
    attendance = Attendance.where("company_id=? and user_id=? and month between ? and ?", company_id, id, month.beginning_of_month, month.end_of_month).first unless month.blank?
    attendance.days_absent unless attendance.blank?
  end

  def current_month_approved_leaves(month)
    leave_requests = LeaveRequest.where("company_id=? and user_id=? and leave_status=? and start_date between ? and ?", company_id, id, 1, month.beginning_of_month, month.end_of_month)
    leaves = leave_requests.count
    leave_requests.each do |leave|
      leaves += (leave.end_date - leave.start_date)
    end
    leaves
  end

  def salary_structure
    SalaryStructure.current_salary_structure(company_id, id, nil)
  end

  def current_year_leaves(month)
    running_year = LeaveCard.running_year(month)
    LeaveCard.where(:company_id =>company_id, :user_id=> id, :card_year=>running_year).sum(:total_leave_cnt)
  end

  def current_year_utilized_leaves(month)
    running_year = LeaveCard.running_year(month)
    LeaveCard.where(:company_id =>company_id, :user_id=> id, :card_year=>running_year).sum(:utilized_leave_cnt)
  end


  def variable_pay(month)
    variable_payhead_details.where(:month=>month.beginning_of_month..month.end_of_month).sum(:amount)
  end

  def net_salary(month)
    salaries = Salary.includes(:payhead).where(:user_id=>id, :month=>month.beginning_of_month..month.end_of_month)
    net_salary=0
    salaries.each {|salary| net_salary += salary.payhead.payhead_type!="Earnings" ? -1*salary.amount : salary.amount }
    net_salary
  end

  def net_salary_computed(month)
    salaries = SalaryComputationResult.includes(:payhead).where(:user_id=>id, :month=>month.beginning_of_month..month.end_of_month)
    net_salary=0
    salaries.each {|salary| net_salary += salary.payhead.payhead_type!="Earnings" ? -1*salary.amount : salary.amount }
    net_salary
  end

  def gross_salary(month)
    total = 0
    salary_structure = SalaryStructure.current_salary_structure(company_id, id, month)
    unless salary_structure.blank?
      salary_structure.salary_structure_line_items.includes(:payhead).each do |line_item|
        if line_item.payhead.payhead_type == "Earnings"
          total += line_item.amount
        else
          total -= line_item.amount
        end
      end
    end
    total
  end

  def avatar_name
    avatar_file_name
  end

  def avatar_size
    avatar_file_size
  end


  def delete_avatar
    @avatar_delete ||= "0"
  end

  def delete_avatar=(value)
    @avatar_delete = value
  end
#-------------------------

  #user full name
  def full_name
    if prefix.blank?
      first_name.capitalize+" "+last_name.capitalize
    else
       prefix+" "+first_name.capitalize+" "+last_name.capitalize
    end
  end

  # code for multi step form start
  def current_step
    @current_step || steps.first
  end

  def steps
    %w[basic personal work usernote]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def self.company_users(company)
    users = User.where(:company_id=> company, :deleted=> false)
    arr=[]
    users.each do |user|
      hash={}
      hash["id"]= user.id
      hash["name"]= user.full_name
      arr<<hash
    end
    arr.to_json
  end
  # code for multi step form end

  #naveen 2017-05-11
  #This method shows if the user is owner or HR role to edit
  #the employee records
  def can_edit?
    self.owner? || self.hr?
  end

  def owner?
    self.roles.any?{|role| role.name == "Owner"}
  end

  def accountant?
    self.roles.any?{|role| role.name == "Accountant"}
  end

  def staff?
    self.roles.any?{|role| role.name == "Staff"}
  end

  def employee?
    self.roles.any?{|role| role.name == "Employee"}
  end

  def hr?
    self.roles.any?{|role| role.name == "HR"}
  end

  def sales?
    self.roles.any?{|role| role.name == "Sales"}
  end

  def auditor?
    false
  end

  def inventory_manager?
    self.roles.any?{|role| role.name == "Inventory Manager"}
  end

  def can_view?(user)
    (self.id == user.id) || self.owner? || self.hr?
  end

  def can?(action,resource)
    roles.includes(:rights).for(action,resource).any?
  end

  def self.authenticate(name, password)
    # user = self.find_by_username(name)
    user=self.where("username=BINARY ?", name).first
    if user
      expected_password = encrypt_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end

  #'password' is a virtual attribute
  def password
    @password
  end

  def password= (pwd)
    @password =pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypt_password( self.password, self.salt)
    self.reset_password = false
  end

  def self.get_user_ids(company,user)
    users = self.where(:company_id => company).where("first_name like ? or last_name like ?",user,user)
    @user_ids = []
    if !users.blank?
      users.each do |u|
        @user_ids << u.id
      end
    end
    @user_ids
  end

	def self.users_in_company(user_id)
		User.find(user_id).company.users
	end

	def self.last_month
	   User.where("last_login_time between ? and ?", Time.zone.now.to_date.months_ago(1), Time.zone.now.to_date.end_of_month)
	end

 def self.last3_month
     User.where("last_login_time between ? and ?", Time.zone.now.to_date.months_ago(3), Time.zone.now.to_date)
  end

  def self.last6_month
     User.where("last_login_time between ? and ?", Time.zone.now.to_date.months_ago(6), Time.zone.now.to_date)
  end

  def self.last9_month
     User.where("last_login_time between ? and ?", Time.zone.now.to_date.months_ago(9), Time.zone.now.to_date)
  end

  def self.last12_month
     User.where("last_login_time between ? and ?", Time.zone.now.to_date.months_ago(12), Time.zone.now.to_date)
  end

  # def get_users_role
  #     user = User.find(id)
  #     role = user.roles[0].name unless user.roles[0].blank?
  # end

  # def role_name
  #   roles[0].name
  # end

  #user joined in current month
  def self.current_month
     User.where("created_at between ? and ?", Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date.end_of_month)
  end

  def self.all_remaining_users user
    where("company_id = ? and id != ?", user.company_id, user.id)
  end

   def self.all_owner_and_hr user
    joins(:roles).where("company_id = ? and deleted=0 and name in (?,?) and users.id != ?", user.company_id,"HR","OWNER",user.id)
  end

  def register_user_action(remote_ip, action, current_user)
    Workstream.register_user_action(company_id, current_user.id, remote_ip," user successfully with username #{username} ", action, branch_id )
  end

  def utilized_storage
   subscription = Subscription.find_by_status_id_and_company_id([1,2], company_id)
   subscription.increase_storage(avatar_file_size, old_file_size)
  end

  #[FIXME] we need to log the delete action. Is this method being used?
  def delete(deleted_by)
    result = false
    pass = User.find id
    transaction do
      if update_attributes!(:deleted => true, :deleted_by => deleted_by, :deleted_datetime => Time.zone.now)
        result = true
      end
    end
    result
  end

  def restore(restored_by)
    result = false
    pass = User.find id
    transaction do
      if update_attributes!(:deleted => false, :restored_by => restored_by, :restored_datetime => Time.zone.now)
        result = true
      end
    end
    result
  end

  def active?
    !deleted?
  end

  def save_with_leave_card(company)
    company = Company.find_by_id(company.id)
    leave_types = company.leave_types
    result = false
    transaction do
      save
      for leave_type in leave_types
      leave_card = LeaveCard.new(:company_id => company.id,
                                 :user_id => id,
                                 :leave_type_id => leave_type.id,
                                 :card_year => Time.zone.now.year,
                                 :total_leave_cnt => leave_type.allowed_leaves,
                                 :utilized_leave_cnt => 0)
        leave_card.save
      end
    result = true
    end
    result
  end

  def user_total_leave_count
    leave_cards = LeaveCard.where(:user_id => id, :card_year => Time.zone.now.year)
    leave_cards.sum(:total_leave_cnt)
  end

  def user_utilized_leave_count
    leave_cards = LeaveCard.where(:user_id => id, :card_year => Time.zone.now.year)
    leave_cards.sum(:utilized_leave_cnt)
  end

  def user_pending_leave_count
    user_total_leave_count - user_utilized_leave_count
  end

  def earnings
    if !self.user_referral.blank?
      earning = self.user_referral.referral_balance unless self.user_referral.referral_balance.blank?
    else
      earning = 0
    end
  end

  private
    def password_non_blank
      errors.add(:password, "Missing password, please enter your password") if hashed_password.blank?
    end

    def user_limit
      errors[:base] << "User limit reached, your plan does not allow creating any more users." if Subscription.user_limit? company_id
    end

    def create_new_salt
      self.salt = self.object_id.to_s + rand.to_s
    end

    def self.encrypt_password(password, salt)
      string_to_hash = password +"prftnxt" + salt
      Digest::SHA1.hexdigest(string_to_hash)
    end

    def destroy_avatar?
      self.avatar.clear if @avatar_delete == "1" and !avatar.dirty?
    end

    def storage_limit
      errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(id, avatar_file_size, old_file_size)
    end

end
