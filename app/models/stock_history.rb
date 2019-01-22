class StockHistory < ActiveRecord::Base
	belongs_to :stock
	belongs_to :company
	belongs_to :financial_year
	class << self
		def create_history(stock, financial_year)
			stock_history=StockHistory.create!(:company_id=>financial_year.company.id, :stock_id=>stock.id,
				:financial_year_id=>financial_year.id, :opening_stock=>stock.opening_stock,
				:opening_stock_value=> stock.opening_stock_unit_price)
			stock_history
		end
	end
end