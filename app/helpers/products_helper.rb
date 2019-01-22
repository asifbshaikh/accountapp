module ProductsHelper

	def product_specific_target
		@product.batch_enable? ? "#modal-batch" : "#modal-warehouse"
	end
end
