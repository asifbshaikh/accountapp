class Currency < ActiveRecord::Base
  has_many :companies, :through => :company_currencies
  has_many :company_currencies
  has_many :payment_vouchers
  #has_many :invoices

  class << self
    def list
      currencies = Currency.all
      currency_arr=[]
      currencies.each do |currency|
        cur=[]
        cur<<currency.id
        cur<<currency.currency_code
        currency_arr<<cur
      end
      currency_arr
    end

    #Returns the currency code
    def self.find_by_currency_code(code)
      if code.present?
        Currency.find_by_currency_code(code)
      else
        super
      end
    end

  end #end class self block   

end