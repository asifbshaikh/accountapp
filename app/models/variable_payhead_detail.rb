class VariablePayheadDetail < ActiveRecord::Base
 belongs_to :user
 belongs_to :company
 belongs_to :payhead
 
 validates_presence_of :company_id, :user_id, :payhead_id, :amount, :month

 def self.check_payroll_discard(company_id, payroll_month)
 	self.where(:company_id => company_id, :month => payroll_month.beginning_of_month..payroll_month.end_of_month).count > 0 ? false : true
 end
end
