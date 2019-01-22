require 'digest/sha1'
require 'active_support/secure_random'

class Auditor < ActiveRecord::Base
  has_many :companies, :through => :company_auditors
  has_many :company_auditors, :dependent => :destroy
  has_many :auditor_assignments
  has_many :client_invitations
  has_many :roles, :through => :auditor_assignments
  validates :first_name, :last_name,  :username, :presence => true
  validates_format_of :username, :with =>  /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i
  validates_uniqueness_of :username
  attr_accessible :reset_password, :password, :password_confirmation, :username, :first_name,:last_name
  attr_reader :password
  validates_presence_of :password, :on => :create
  attr_accessor :password_confirmation
  validates_confirmation_of :password, :on => :create
  validate :password_must_be_present
  def email
    username
  end
  def last_login

  end


  def role_name
    self.roles[0].name
  end
  
  def branch
  end

 def self.authenticate(name, password)
  	if auditor = find_by_username(name)
  	  if auditor.hashed_password == encrypt_password(password, auditor.salt)
  	    auditor
      end
  	end
  end

  def self.encrypt_password(password, salt)
    Digest::SHA1.hexdigest(password + "profitbooks_auditor" + salt)
  end

  # 'password' is a virtual attribute
  def password=(password)
  	@password = password
    if password.present?
      generate_salt
  	  self.hashed_password = Auditor.encrypt_password(password, salt)
  	end
  end

  def new_password
    random_str = SecureRandom.base64(9)
    self.password = random_str
    self.reset_password = true
    self.save
    random_str
  end

  def save_with_company(comp_id, invitation_detail_id)
    result = false
    comp = Company.find(comp_id)
    transaction do
      if save
       CompanyAuditor.create(:company_id => comp_id, :auditor_id => id)
       AuditorAssignment.create(:auditor_id => id, :role_id => comp.plan.roles.find_by_name("Auditor").id)
       invitation_detail = InvitationDetail.find invitation_detail_id
       invitation_detail.update_attribute(:status_id,  1)
       result = true
      end
    end
    result
  end

  def can?(action, resource)
    roles.includes(:rights).for(action,resource).any?
  end

  #user full name
  def full_name
    first_name.capitalize+" "+last_name.capitalize
  end
  def owner?
    false
  end
  def inventory_manager?
   false
  end
  def staff?
    false
  end
  def accountant?
   false
  end
  def employee?
    false
  end
  def hr?
    false
  end

  def sales?
    false
  end
  def auditor?
    self.roles.any?{|role| role.name == "Auditor"}
  end

  private
    def password_must_be_present
      errors.add(:password, "Missing password") unless hashed_password.present?
    end

    def generate_salt
      self.salt = self.object_id.to_s + rand.to_s
    end
end
