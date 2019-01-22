module InventorySettingsHelper
  def inventory_effect_setting
    if @inventory_setting.purchase_effects_inventory?
      'Inventory is affected on entry of purchase voucher.'
    else
      'Inventory is NOT affected on entry of purchase voucher.'
    end
  end
end
