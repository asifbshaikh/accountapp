class ProductPricingLevel < ActiveRecord::Base
	belongs_to :company
	has_many :sundry_debtors
	class << self
		def create_pricing_levels(company)
			5.times do |i|
				self.create!(:company_id => company.id, :caption => "Level#{i+1}")
			end
		end
	end
end
