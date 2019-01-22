class Salaries < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  has_many :ledgers, :as => :voucher, :dependent => :destroy
   # def amount(company_id, month, fy)
   #  year = (month.to_i < fy.start_date.month ?  fy.end_date.year : fy.start_date.year )
   #  date = Date.new(year.to_i, month.to_i, 1)
   #  @company = Company.find_by_id(company_id)
   #  @users = @company.users
   #  logger.info"@@@ users in company is #{@users.count} and company name is #{@company.name}"
    
   #  for user in @users
   #   @salaries = Salries.find_all_by_user_id_and_month(user.id, date..date.end_of_month)
   #     for salary in @salaries
   #       payhead = Payhead.find(salary.payhead_id) 
	  #      if payhead.payhead_type == "Earnings" 
	  #        @earning_amount_arr << salary.amount
	  #        @total_earning +=salary.amount
	  #        logger.info"@@@ total earning amount is #{@total_earning}"
	  #      else
	  #        @deduction_amount_arr << salary.amount
	  #        @total_deduction +=salary.amount
	  #        logger.info"@@@total deducted amount is #{@total_deduction}"
	  #      end 
   #         @net_amount = @total_earning - @total_deduction
   #      end
   #      @net_amount
   #      logger.info"@@@total net salary is #{@net_amount}" 
   #  end 	
   # end

end
