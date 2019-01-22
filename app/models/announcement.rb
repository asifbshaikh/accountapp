class Announcement < ActiveRecord::Base

  class << self

    def create_new(params, user)
      announcement = Announcement.new(params[:announcement])
      announcement.user_id = user.id
      announcement
    end

    def current(company, hidden_ids = nil)
      result = where("company_id = :company_id and starts_at <= :now and ends_at >= :now", :company_id => company.id, :now => Time.zone.now).limit(5).all
      result = result.where("id not in (?)", hidden_ids).limit(5) if hidden_ids.present?
      result
    end

  end

end
