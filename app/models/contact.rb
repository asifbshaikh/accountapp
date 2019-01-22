class Contact < ActiveRecord::Base

  #relationships
  belongs_to :user
  belongs_to :sundry_debtor
  #validation start

  # validates_presence_of :title, :first_name, :last_name, :gender, :email, :address1, :phone1,:mobile,
  #                        :city,:pin_code,:contact_category, :account, :company

  # validates_uniqueness_of :email, :phone1,  :mobile, :address1
  # validates_uniqueness_of :phone2, :allow_nil => true

  validates_length_of :first_name, :last_name ,:maximum =>150, :allow_nil => true
  validates_length_of :phone1, :phone2 ,:mobile ,:maximum => 10, :allow_nil => true
  validates_length_of :notes, :maximum => 300, :allow_nil => true

  validates_format_of :email,
                    :with =>  /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i,
                    :message => ":Its not a valid format", :allow_nil => true
  validates_format_of :pin_code, :with => /^(^([0-9]{5})$)|(^([0-9]{6})$)/i,
                      :message => ":Its not a valid format", :allow_nil => true

  validate :address1_and_address2_validation
  def address1_and_address2_validation
    unless address1.blank? && address2.blank?
      if self.address1 == self.address2
        errors.add_to_base("Address1 must be different from Address2")
      end
    end
  end

  validate :phone1_and_phone2_validation

  def phone1_and_phone2_validation
    unless phone1.blank? && phone2.blank?
      if self.phone1 == self.phone2
        errors.add_to_base("phone1 must be different from phone2")
      end
    end
  end

end

