class SalaryStructureHistory < ActiveRecord::Base
  belongs_to :company
   belongs_to :salary_structure
   has_many :salary_structure_history_line_items, :dependent => :destroy
   belongs_to :user
   accepts_nested_attributes_for :salary_structure_history_line_items, :reject_if => lambda {|p| p[:payhead_id].blank? && p[:amount].blank? }, :allow_destroy => true

  #validation
   # validates_presence_of :salary_structure_history_line_items
   validates_associated :salary_structure_history_line_items

  def self.last_five( company_id, user_id)
    where(:company_id => company_id, :for_employee=> user_id).limit(5).order("created_at DESC")
  end

 def for_employee_name
   User.find(for_employee).full_name
  end
  def created_by_user
    User.find(created_by).full_name
  end

 def total_amount
    total = 0
    self.salary_structure_history_line_items.each do |line_item|
        amount =  line_item.amount
       payhead_type = Payhead.find(line_item.payhead_id).payhead_type
      if payhead_type == 'Earnings'
        total = total+amount
      else
         total = total-amount
      end
    end
    total
  end

end
