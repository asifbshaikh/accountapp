class Inventory < ActiveRecord::Base
  belongs_to :company

  def account_name
      Account.find(inventory.account_id).name
  end
end
