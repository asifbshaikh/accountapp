class ProductCatalogController < ApplicationController

	def index
		@products = @company.products
		respond_to do |format|
			format.html
			format.pdf
			format.xls 
		end
		
	end

end
