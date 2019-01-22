class AddGstReturnToGstrOnes < ActiveRecord::Migration
  def change
    add_column :gstr_ones, :gst_return_id, :integer, :null => false
  end
end
