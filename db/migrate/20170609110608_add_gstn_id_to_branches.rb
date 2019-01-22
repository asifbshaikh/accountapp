class AddGstnIdToBranches < ActiveRecord::Migration
  def change
    add_column :branches, :gstn_id, :string
  end
end
