require 'digest/sha2'
class SuperUser < ActiveRecord::Base

  has_many :leads, :foreign_key=> "assigned_to"
  validates_presence_of :username, :first_name, :last_name, :email
  validates_presence_of :password, :on => :create
  attr_accessor :password_confirmation
  validates_confirmation_of :password, :on => :create
  attr_accessible :active, :first_name, :last_name, :username, :email, :password, :password_confirmation

  def self.authenticate(name, password)
    super_user = self.find_by_username(name)
    if super_user && super_user.deleted?
      expected_password = encrypt_password(password, super_user.salt)
      if super_user.hashed_password != expected_password
        super_user = nil
      end
    else
      super_user = nil
    end
    super_user
  end

  def self.list_user_options 
    SuperUser.where(:active => true).select("first_name, id").map {|x| [x.first_name, x.id] }
  end

  def self.super_user_names
    super_users = self.where(:active => true)
    arr=[]
    super_users.each do |super_user|
      hash={}
      hash["id"]=super_user.id 
      hash["super_user_name"]=super_user.first_name
      arr<<hash
    end
    arr.to_json
  end

  # 'password' is a virtual attribute
  def password
    @password
  end
  
  def password= (pwd)
    @password =pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = SuperUser.encrypt_password( self.password, self.salt)
  end
  
  def full_name
    self.first_name.capitalize + ' ' + self.last_name.capitalize
  end

  def delete
    result = false
    pass = SuperUser.find id
    transaction do
      if update_attributes!(:active => false)
        result = true
      end
    end
    result
  end

  def restore
    result = false
    pass = SuperUser.find id
    transaction do
      if update_attributes!(:active => true)
        result = true
      end
    end
    result
  end
  
  def deleted?
    active?
  end


  private

    def password_non_blank
      errors.add(:password, "Missing password, please enter your password") if hashed_password.blank?
    end

    def create_new_salt
      self.salt = self.object_id.to_s + rand.to_s
    end
    
    def self.encrypt_password(password, salt)
      Digest::SHA2.hexdigest(password + "profitbooks_admin" + salt)
    end
  
end
