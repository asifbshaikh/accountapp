class SalaryStructureHistoryLineItem < ActiveRecord::Base
   belongs_to :salary_structure_history
   belongs_to :payhead
   # validates_presence_of :payhead_id
   # validates :amount, :numericality => {:greater_than_or_equal_to => 0.00,
   #                                      :message => " should not be negative ." }
   # validates :payhead_id, :uniqueness => {:scope => :salary_structure_id, :message => "should once per salary structure entry" }

end
