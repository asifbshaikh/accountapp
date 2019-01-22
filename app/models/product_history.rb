class ProductHistory < ActiveRecord::Base
	belongs_to :product
	belongs_to :company
	belongs_to :financial_year
	class << self
		def create_history(product, financial_year)
			ProductHistory.create!(:company_id=>financial_year.company.id, :product_id=>product.id,
				:financial_year_id=>financial_year.id, :opening_stock=>product)

		end
	end
end
