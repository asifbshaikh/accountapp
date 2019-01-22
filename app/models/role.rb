class Role < ActiveRecord::Base
  has_many :grants
  has_many :assignments
  has_many :user, :through => :assignments
  has_many :auditor_assignments
  has_many :auditors, :through => :auditor_assignments
  has_many :rights, :through => :grants
  belongs_to :plan
  scope :for, lambda{|action, resource|
                where("rights.operation = ? and rights.resource = ?",
                  Right::OPERATION_MAPPINGS[action], resource
                )
              }

  def self.owner_list
    owner = []
    plan_list = []
    plans = Plan.where(:active => true)
    plans.each do |p|
      plan_list << p.id
    end
    roles = Role.where(:name => "Owner")
    roles.each do|r|
      owner << r.id
    end
    owner
  end

end
