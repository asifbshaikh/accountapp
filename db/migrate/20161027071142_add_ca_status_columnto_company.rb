class AddCaStatusColumntoCompany < ActiveRecord::Migration
  def change
    add_column :companies, :ca_status, :integer, :null => true
    add_column :users, :feedback, :integer, :null => true
    add_column :users, :feedback_comment, :text, :null => true
  end
end
