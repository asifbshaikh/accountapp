class Pbreferral < ActiveRecord::Base

  belongs_to :company
  belongs_to :user
  belongs_to :coupon

  validates_presence_of :email
  validates_format_of :email, :with =>  /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i, :uniqueness => true, :message => "should be valid email"

  STATUS = {'0' => "Unregistered", '1' => "Registered", '2' => "Paid"}

  class << self
    def get_status_id(index)
        string = index
      if /unregisteres|Unregisteres/i.match(string)
        value = "Unregistered"
      elsif /registered|Registered/i.match(string)
        value = "Registered"
      elsif /paid|Paid/i.match(string)
        value = "Paid"
      end
      STATUS.index(value.to_s)
    end

    def convert_to_paid(user,coupon_code, company, amount)
      coupon = Coupon.find_by_coupon_code(coupon_code)
      # logger.info"@@@ amount is #{amount}"

      # earning = amount.to_f*(25.0/100.0)
      # logger.info"@@@ earning is #{earning}"

      if !coupon.blank?
        pbreferral = Pbreferral.find_by_email_and_coupon_id_and_invitee_company_id_and_status(user.email, coupon.id, company.id, 1)
        if !pbreferral.blank?
           if pbreferral.update_attributes(:status => 2, :earning => 3)
            user_referral = UserReferral.find_by_company_id_and_user_id(pbreferral.company_id, pbreferral.invited_by)
            if !user_referral.blank?
              new_count = user_referral.paid_referral_count + 1
              new_bal = user_referral.referral_balance + 3
              user_referral.update_attributes(:paid_referral_count => new_count, :referral_balance=> new_bal)
              subscription = Subscription.find_by_company_id(user_referral.company_id)
              if !subscription.blank?
              new_date = subscription.end_date+3.months
              subscription.update_attributes(:end_date=> new_date, :renewal_date=> new_date)
              end
             Email.referral_paid(pbreferral).deliver
            end
           end
        end
      end
    end

 end

  def inviter_name
    User.find(invited_by).first_name
  end

  def get_status
    stat_arr = ['Unregistered', 'Registered', 'Paid']
    stat_arr[status]
  end

  def register_user_action(remote_ip, action, current_user)
    Workstream.register_user_action(company_id, current_user.id, remote_ip,"Referral successfull with #{email}", action, current_user.branch_id )
  end

end
