class AddStatusToImportFiles < ActiveRecord::Migration
  def change
	add_column :import_files, :status, :integer
  end
end
