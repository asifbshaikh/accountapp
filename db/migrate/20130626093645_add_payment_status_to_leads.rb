class AddPaymentStatusToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :payment_status, :boolean
  end

  def self.down
    remove_column :leads, :payment_status
  end
end
