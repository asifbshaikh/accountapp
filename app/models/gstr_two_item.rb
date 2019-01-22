class GstrTwoItem < ActiveRecord::Base
  belongs_to :gstr_two
  belongs_to :voucher, :polymorphic  => true 
  belongs_to :company

   STATUS = {open: 0, uploaded: 1, error: 2, final: 3}

  def update_error_status(error_cd, error_msg)
    update_attributes(status: STATUS[:error], error_msg: "#{error_cd} #{error_msg}")
  end

   def remove_error
    update_attributes(status: STATUS[:uploaded], error_msg: nil)
  end

  
end
