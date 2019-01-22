class Gsp < ActiveRecord::Base

  class << self

    #[FIXME] Improve algorithm
    def allocate_gsp
      gsps = Gsp.where(:env => Rails.env)
      gsps.first
    end
  end
end
