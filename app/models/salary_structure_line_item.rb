class SalaryStructureLineItem < ActiveRecord::Base
  belongs_to :salary_structure
  belongs_to :payhead

  #validation
  validates_presence_of :payhead_id
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.00,
    :message => " should not be negative ." }
  validates :payhead_id, :uniqueness => {:scope => :salary_structure_id, :message => "should once per salary structure entry" }

  def calculate_salary_for_this_month(attendance)
    if self.payhead.fixed?
      total = amount
    else
      total = amount
      # last_salary_structure = SalaryStructure.order("effective_from_date DESC").where("effective_from_date < ? and company_id=? and for_employee=?", @salary_structure.effective_from_date, @company.id, @salary_structure.for_employee).first
      if attendance.days_absent > 0
        days_absent=attendance.days_absent
        per_day_pay = amount/attendance.month.end_of_month.day
        logger.info"per_day_pay=#{per_day_pay}"
        user = attendance.user
        leave_requests = LeaveRequest.where("company_id=? and user_id=? and leave_status=? and start_date between ? and ?", attendance.company_id, user.id, 1, attendance.month.beginning_of_month, attendance.month.end_of_month)
        leave_requests.each do |leave_request|
          leave_days=0
            unless leave_request.leave_type.paid?
              leave_days=(leave_request.end_date-leave_request.start_date+1)
              logger.info"leave_days=#{leave_days} and days_absent=#{days_absent}"
              if days_absent<=0
                leave_days=0
              elsif days_absent<leave_days
                leave_days=days_absent
              end
              total -= per_day_pay*(leave_days)
            end
          days_absent-=leave_days
        end
        if days_absent>0
          total-=per_day_pay*(days_absent)
        end
      end
      total
    end
  end

end
