# ProfitBooks.net
# Copyright (C) 2011-2012 by The Nextwave Technologies.
#
# This program is licensed to The Nextwave Technologies.
# This code cannot be copied, recproduced in anyway except with prior written
# permission of The Nextwave Technologies.
#------------------------------------------------------------------------------

# == Schema Information
# Schema version: 01 
#
# Table name: plans
#
#  id              integer(11)      not null, primary key
#  name            varchar 255      null  
#
class Plan < ActiveRecord::Base
  has_many :subscriptions
  has_many :subscription_histories
  has_many :companies, :through => :subscriptions
  has_many :roles
  has_many :plan_properties

  class << self
    def free
      find_by_name('PWYW') 
    end

    def essential
      find_by_name('Essential')
    end

    def basic
      find_by_name('Basic')
    end

    def trial
      find_by_name('Trial')
    end

    def smb
      find_by_name('SMB')
    end

    def premium
      find_by_name('SMB')
    end

    def enterprise
      find_by_name('Enterprise')
    end

    def professional
      find_by_name('Professional')
    end

    def upgradable_plans(price)
      Plan.where("price > ? and active = ?", price, true).order("price ASC")
    end  
  end
  def annual_price(validity,coupon)
    limit = !coupon.blank? ? coupon.year*12 : 0
    plan_total = price * validity
    validity_discount = 0
    if limit ==0 
      if validity == 24 
          validity_discount = 20
      elsif validity == 36
        validity_discount = 30
      elsif validity == 60
          validity_discount = 50
      end
       discount = plan_total * (validity_discount / 100.0)
 
     elsif limit == validity
      discount = coupon.discount
    end  

   plan_total 

  end

  def is_inventoriable?
    plan_properties.find_by_name('inventoriable').value == '1' 
  end

  def payroll_enabled?
    plan_properties.find_by_name('payroll').value == '1' 
  end

  def free_plan?
    plan_properties.find_by_name('free_plan').value == '1'
  end

 

  def essential_plan?
    name == 'Essential'
  end
   def enterprise_plan?
    name == 'Enterprise'
  end
  def trial_plan?
    name == 'Trial'
  end
  def smb_plan?
    name == 'SMB'
  end
  def professional_plan?
    name == 'Professional'
  end


  def foreign_plan?
    properties = plan_properties.find_by_name('foreign_plan')
    properties.value == '1' unless properties.nil?
  end

end
