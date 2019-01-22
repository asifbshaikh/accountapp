class UserReferral < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
 
 class << self
    def maintain_detail(company_id, user_id, referral_count)
      user_referral = UserReferral.find_by_company_id_and_user_id(company_id, user_id)
      if user_referral.blank?
        user_referral = UserReferral.new(:company_id => company_id, :user_id=> user_id, :referral_count => referral_count)
        user_referral.save
      else
        user_referral.referral_count += referral_count
        user_referral.save
      end
    end

    def update_balance(company, user, amount)
      user_referral = UserReferral.find_by_company_id_and_user_id(company.id, user.id)
      if !user_referral.blank?  
        new_bal = user_referral.referral_balance - amount
        user_referral.update_attributes(:referral_balance => new_bal)
      end
    end
    
   end
end
