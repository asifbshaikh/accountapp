class AddGstReturnIdToGstrTwo < ActiveRecord::Migration
  def change
    add_column :gstr_twos, :gst_return_id, :integer, :null => false
  end
end
