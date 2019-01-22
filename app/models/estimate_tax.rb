class EstimateTax < ActiveRecord::Base
	belongs_to :estimate_line_item
	belongs_to :account
end
