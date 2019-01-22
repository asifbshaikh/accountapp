class AddGstrReferanceIdToGstrTwo < ActiveRecord::Migration
  def change
    add_column :gstr_twos, :gst_reference, :string
  end
end
