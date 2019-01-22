module WarehousesHelper
	def warehouse_name(warehouse_id)
		raw("<b>#{Warehouse.find(warehouse_id).name}</b>") unless warehouse_id.blank?
	end
	def warehouse_label
		@company.label.warehouse_label
	end
end
