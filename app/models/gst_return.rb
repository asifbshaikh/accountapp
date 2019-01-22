class GstReturn < ActiveRecord::Base
  belongs_to :company
  belongs_to :financial_year
  has_one :gstr_one
  has_one :gstr_two

  class << self
    #[FIXME] Partially complete
    #This method creates the corresponding return entries for a company as follows
    #This method will first check the company registration type and based on that it will create
    #entries in appropriate gst return tables
    #E.G. If company.gst_registration_type is Registered and month is October it will create 
    #following enties an entry for gst_return for given 
    # 1. One record in gst_return table for company and month
    # 2. One record in gstr_one table 
    # 3. One record in gstr_two table
    # 4. One record in gstr3 table
    def create_return(company, month)
      attr = {:company_id => company.id, :financial_year_id => company.financial_years.last.id, :month => month}
      gst_return = (GstReturn.find_by_company_id_and_month(company.id, month) || GstReturn.create!(attr))
    end

    def return_month(month)
      find_by_month(month)
    end
  end
end
