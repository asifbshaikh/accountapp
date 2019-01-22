class LeaveCard < ActiveRecord::Base
  paginates_per 20
  belongs_to :leave_type
  belongs_to :company
  belongs_to :user

  validates_presence_of :total_leave_cnt
  validates :total_leave_cnt, :numericality => {:greater_than => 0,
                                        :message => " should be greater than zero."}
  validates_uniqueness_of :leave_type_id, :scope => [:user_id, :card_year]
  #retreives the leave card of the given user for the current year


  def utilized?

  end
  class << self
    def running_year(month)
      year = Time.zone.now.year
      year = year - 1 if month > Time.zone.now.month
      year
    end
    def create_card(params, company)
      leave_card = LeaveCard.new(params[:leave_card])
      leave_card.company_id = company
      leave_card.card_year=Time.zone.now.year
      leave_card
    end
  end
  def self.current_leave_card(user_id)
    current_year = Time.zone.now.year
    LeaveCard.where("card_year =? and user_id=?", current_year, user_id).includes(:leave_type).page
  end

  def employee_name
   User.find(self.user_id).full_name
  end
  def leave_type_name
    self.leave_type.leave_type
  end

  def pending_leave_count
    total_leave_cnt - utilized_leave_cnt
  end

  def add_to_utilized_leaves (leave_count)
    self.utilized_leave_cnt = utilized_leave_cnt + leave_count
    save
  end

  def revoke_utilized_leaves (leave_count)
    self.utilized_leave_cnt = utilized_leave_cnt - leave_count
    save
  end

end