class RenameColumnNameInBranches < ActiveRecord::Migration
  def up
  	rename_column :branches, :gstn_id, :gstn
  end

  def down
  end
end
