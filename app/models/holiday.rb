class Holiday < ActiveRecord::Base
  #relationship
  belongs_to :user
  belongs_to :company
  
  #validations
  validates_presence_of :holiday_date, :holiday
  #validates :holiday, :uniqueness => { :scope => :year, :message => "should happen once per year" }

  def self.this_month(company)
    Holiday.where("holiday_date between ? and ? and company_id = ?", Time.zone.now.to_date, Time.zone.now.to_date.end_of_month, company.id).order("holiday_date")
  end
  def self.this_week(company)
    Holiday.where("holiday_date between ? and ? and company_id = ?", Time.zone.now.to_date, Time.zone.now.to_date.end_of_week,company.id)
  end

  class << self
    def new_holiday(params, company, user)
      holiday = Holiday.new(params[:holiday])
      holiday.company_id = company
      holiday.created_by = user.id
      holiday
    end
  end
end
