class CreateImportFiles < ActiveRecord::Migration
  def change
    create_table :import_files do |t|
      t.integer :company_id, :null => false
      t.integer :item_type, :null => false
      t.integer :created_by, :null => false

      t.timestamps
    end
  end
end
