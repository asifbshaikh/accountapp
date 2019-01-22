class EmailAction < ActiveRecord::Base
  has_many :email_actions
  def actiondesc
    @actiondesc = {}
    email_actions.each do|t|
      @actiondesc[t.action] = t.description
    end
    Rails.longer.info(@actiondesc.keys)
  end
end
