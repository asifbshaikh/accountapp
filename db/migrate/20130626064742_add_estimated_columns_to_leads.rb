class AddEstimatedColumnsToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :estimated_revenue, :decimal, :precision => 10, :scale => 2
    add_column :leads, :probability, :Integer
    add_column :leads, :plan_of_interest, :Integer
  end

  def self.down
    remove_column :leads, :plan_of_interest
    remove_column :leads, :probability
    remove_column :leads, :estimated_revenue
  end
end
