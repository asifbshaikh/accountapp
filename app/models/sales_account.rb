class SalesAccount < ActiveRecord::Base
	has_one :account, :as => :accountable
end
