class AddAttachmentFileToImportFile < ActiveRecord::Migration
  def self.up
    add_column :import_files, :file_file_name, :string
    add_column :import_files, :file_content_type, :string
    add_column :import_files, :file_file_size, :integer
    add_column :import_files, :file_updated_at, :datetime
  end

  def self.down
    remove_column :import_files, :file_file_name
    remove_column :import_files, :file_content_type
    remove_column :import_files, :file_file_size
    remove_column :import_files, :file_updated_at
  end
end
