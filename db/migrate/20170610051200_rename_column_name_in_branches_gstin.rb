class RenameColumnNameInBranchesGstin < ActiveRecord::Migration
  def up
  	rename_column :branches, :gstn, :gstin
  end

  def down
  end
end
