module InventoryStatementsHelper
include ActsAsTaggableOn::TagsHelper
	def average_price(total_amount, total_quantity)
		((total_amount == 0 || total_quantity == 0) ? 0.00 : (total_amount/ total_quantity))
	end

end
