# ProfitBooks.net
# Copyright (C) 2011-2013 by The Nextwave Technologies.
#
# This program is licensed to The Nextwave Technologies.
# This code cannot be copied, recproduced in anyway except with prior written
# permission of The Nextwave Technologies.
#------------------------------------------------------------------------------

# == Schema Information
# Schema version: 01
#
# Table name: subscriptions
#
#  id              :integer(4)      not null, primary key
#
# Values of status column and what they mean
#--------------------------------------------
# 1                 Means the company is on a trail period
# 2                 The company is a paid subscriber
# 3                 The subscription has expired and the company is suspended
#update 07-Dec-2017 I think there should not be an expired status as we shall not know if
#the company subscription expired from trial or paid. In short we won't know the paid status
#
class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :company
  before_save :generate_token, :allocated_user_and_storage, :if => :new_record?

  validates_presence_of :renewal_date

  STATUS = {trial: 1, paid: 2, expired: 3}

  def self.active?(company_id)
    subscription = find_by_company_id(company_id)
    subscription.status_id == 2 || subscription.status_id == 1
  end

  def self.suspended?(company_id)
    subscription = find_by_company_id(company_id)
    subscription.status_id == 3
  end

  def allocated_user_and_storage
    if plan.name == 'Essential'
      self.allocated_user_count = 3
    elsif plan.name == 'Basic'
      self.allocated_user_count = 5
    elsif plan.name == 'SMB'
      self.allocated_user_count = 10
    elsif plan.name == 'PWYW'
      self.allocated_user_count = 1
    elsif plan.name == 'Enterprise'
      self.allocated_user_count = 10
    elsif plan.name == 'Trial'
      self.allocated_user_count = 3
    elsif plan.name == 'Professional'
      self.allocated_user_count = 10
    end
    self.allocated_storage_mb = 1.gigabyte
    #self.utilized_user_count = 1
  end

  def upgrade_plan(plan_name, amount, validity)
    validity = (validity*30).ceil
    new_plan = Plan.find_by_name(plan_name)
    # transaction do
      subscription_history = SubscriptionHistory.create!(
        :company_id => self.company_id,
        :plan_id => self.plan_id,
        :start_date => self.start_date,
        :end_date => self.end_date,
        :renewal_date => self.renewal_date,
        :first_subscription_date => self.first_subscription_date,
        :ip_address => self.ip_address,
        :amount => self.amount,
        :allocated_storage_mb => self.allocated_storage_mb,
        :allocated_user_count => self.allocated_user_count
      )
      user_count = self.allocated_user_count - self.plan.user_count + new_plan.user_count
      edate = subscription_history.end_date > Time.now ? subscription_history.end_date : Time.now
      self.update_attributes!(
        :plan_id => new_plan.id,
        :start_date => Time.zone.now,
        :end_date => (edate + validity.to_i.days),
        :status_id => 2,
        :renewal_date => (edate + validity.to_i.days),
        :amount => amount,
        :allocated_user_count => user_count,
        :allocated_storage_mb => new_plan.storage_limit_mb
      )
      if Subscription.find(self.id).plan.name != 'Essential' && self.company.warehouses.blank?
  	    warehouse = Warehouse.new
  	    warehouse.company_id = self.company_id
  	    warehouse.created_by = self.company.users.first.id
  	    warehouse.name = 'default warehouse'
  	    warehouse.save
  	  end
     #update users enrolled with appropriate roles in new plans
      if subscription_history.plan_id != self.plan_id
        if plan.name=='PWYW'
          user = company.users.first
          user.roles[0] = new_plan.roles.find_by_name(user.roles[0].name)
          user.save!
        else
          self.company.users.each do |user|
            new_role = new_plan.roles.find_by_name(user.roles[0].name)
            user.roles[0].id = new_role.id
            user.save!
          end
        end
      end
    # end
  end

  def add_user_pack(user_pack)
    if !user_pack.blank?
      self.allocated_user_count += user_pack.to_i
      save
    end
  end

  # Apply discount coupon
  def apply_discount_coupon(coupon_code, company, user)
    coupon = Coupon.find_by_coupon_code(coupon_code)
    if !coupon.blank?
  	  transaction do
  	    # Creating coupon transaction
    		CouponTransaction.create(
    		  :coupon_id => coupon.id,
    		  :company_id => company,
    		  :user_id => user,
    		  :used => Time.zone.now
    		)
  		 if !coupon.uses_per_coupon.blank? && coupon.coupon_transactions.count >= coupon.uses_per_coupon
  		   coupon.mark_disabled
  		 end
       if coupon.coupon_type == "Referral"
        new_date = self.renewal_date+30.days
        self.update_attributes(:end_date=> new_date, :renewal_date=> new_date)
       end
      end
	  end
  end
   def update_renewal_date
     new_date = self.renewal_date+30.days
     self.update_attributes(:end_date=> new_date, :renewal_date=> new_date)
   end

  def self.user_limit?(company_id)
    subscription = Subscription.find_by_company_id(company_id)
    subscription.utilized_user_count >= subscription.allocated_user_count
  end

  def increment_user_count
    update_attribute(:utilized_user_count, utilized_user_count+1)
  end

  def decrease_user_count
    update_attribute(:utilized_user_count, utilized_user_count-1)
  end

#checking storage limit
  def self.storage_limit?(company_id, current_file_size, old_file_size)
    current_file_size = 0 unless !current_file_size.blank?
    old_file_size = 0 unless !old_file_size.blank?
    subscription = Subscription.find_by_company_id(company_id)
    subscription.utilized_storage_mb + current_file_size - old_file_size.to_i >= subscription.allocated_storage_mb
  end

  def self.increase_storage(company_id, current_file_size, old_file_size)
    current_file_size = 0 unless !current_file_size.blank?
    old_file_size = 0 unless !old_file_size.blank?
    subscription = Subscription.find_by_company_id(company_id)
    subscription.update_attribute(:utilized_storage_mb, (subscription.utilized_storage_mb + current_file_size - old_file_size.to_i))
  end

  def generate_token
    self.token = encrypt_string(id, generate_salt)
  end

  def encrypt_string(id, salt)
    Digest::SHA2.hexdigest(id.to_s + "prftnxt" + salt)
  end

  def self.update_status(id, token)
    result = false
    subscription = Subscription.find_by_id_and_token(id, token)
    if !subscription.blank? && subscription.update_attribute(:status_id, 1)
      user = subscription.company.users.first
      plan = subscription.plan
      Email.signup_confirmation(user, plan).deliver #unless subscription.status_id == 1
      result = true
    end
    result
  end

  def self.paid_subscription
    where(:status => "Paid")
  end

  def self.expiring_this_week
    where(:renewal_date => Time.zone.now.to_date.beginning_of_week..Time.zone.now.to_date.end_of_week, :status_id => [1,2])
  end

  def self.expiring_in_15_days
    where(:renewal_date=> Time.zone.now.to_date..(Time.zone.now.to_date + 15.days), :status_id =>[1,2])
  end

  # method to upgrade plan from admin menu
  def upgrade_plan_from_admin(plan_id, renewal_date, fin_year)
    new_plan = Plan.find_by_id(plan_id.to_i)
    transaction do
      subscription_history = SubscriptionHistory.create!(
        :company_id => self.company_id,
        :plan_id => self.plan_id,
        :start_date => self.start_date,
        :end_date => self.end_date,
        :renewal_date => self.renewal_date,
        :first_subscription_date => self.first_subscription_date,
        :ip_address => self.ip_address,
        :amount => self.amount,
        :allocated_storage_mb => self.allocated_storage_mb,
        :allocated_user_count => self.allocated_user_count
      )

      user_count = self.allocated_user_count - self.plan.user_count + new_plan.user_count
      self.update_attributes!(
        :plan_id => new_plan.id,
        :renewal_date => renewal_date,
        :end_date => renewal_date,
        :allocated_user_count => user_count
      )

      if Subscription.find(self.id).plan.is_inventoriable? && self.company.warehouses.blank?
         Warehouse.create_default_warehouse(self.company_id, self.company.users.first.id)
      end
      if Subscription.find(self.id).plan.payroll_enabled? && self.company.leave_types.blank?
        LeaveType.create_default_leave_types(self.company_id, self.company.users.first.id)
      end

     if Subscription.find(self.id).plan.payroll_enabled? && self.company.holidays.blank?
          year = (Time.zone.now.to_date.month.to_i < fin_year.start_date.month ?  fin_year.end_date.year : fin_year.start_date.year )
          holiday_date1 = Date.new(year.to_i, 1, 26)
          holiday_date2 = Date.new(year.to_i, 8, 15)
          holiday_date3 = Date.new(year.to_i, 10, 02)
          holiday = Holiday.create(:company_id => self.company_id, :created_by => self.company.users.first.id, :holiday=> "Republic day", :holiday_date => holiday_date1, :description =>"Republic day of India")
          holiday = Holiday.create(:company_id => self.company_id, :created_by => self.company.users.first.id, :holiday=> "Independance Day", :holiday_date => holiday_date2, :description =>"Independance day of India")
          holiday = Holiday.create(:company_id => self.company_id, :created_by => self.company.users.first.id, :holiday=> "Mahatma Gandhi Jayanti", :holiday_date => holiday_date3, :description =>"Gandhi Jayanti celebrated in India to mark the occasion of the birthday of Mahatma Gandhi.")

      end

       if Subscription.find(self.id).plan.payroll_enabled? && self.company.payheads.blank?
         accounts = Account.where(:name => ["Basic","House Rent Allowance", "Dearness Allowance", "Travelling Allowance", "Bonus"],  :company_id => self.company_id)
         if accounts.blank?
         #  Account.create_default_accounts(self.company_id, self.company.users.first.id)
         end
          Payhead.create_default_payheads(self.company_id, self.company.users.first.id)
       end
       if !Subscription.find(self.id).plan.free_plan? && self.company.custom_fields.blank?
          CustomField.create_default_record(self.company_id)
       end
       logger.debug "After subscription attributes"
     #update users enrolled with appropriate roles in new plans
      if subscription_history.plan_id != self.plan_id
        self.company.users.each do |user|
     #      user.roles[0] =  new_plan.roles.find_by_name(user.roles[0].name)
					# user.save
     #      logger.debug "Updated roles"
           new_role = new_plan.roles.find_by_name(user.roles[0].name)
           assignment = Assignment.find_by_user_id(user.id)
           assignment.update_attribute(:role_id, new_role.id)
        end
      end
     end
  end

  private

    def generate_salt
      self.object_id.to_s + rand.to_s + company_id.to_s  + Time.zone.now.to_i.to_s
    end

end
