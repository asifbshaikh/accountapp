class AddNamePanToCasfreeDocument < ActiveRecord::Migration
  def change
  	add_column :cashfree_documents,:name,:string
  	add_column :cashfree_documents, :pan, :string
  end
end
