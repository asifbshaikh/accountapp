class InventorySetting < ActiveRecord::Base
	belongs_to :company
  class << self 
    def find_by_company(company)
      find_by_company_id(company.id)
    end
  end

end
