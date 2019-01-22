class AddErrorMsgToGstrOneItems < ActiveRecord::Migration
  def change
    add_column :gstr_one_items, :error_msg, :string
  end
end
