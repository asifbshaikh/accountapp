class AddCodeTypeToHsnCodes < ActiveRecord::Migration
  def change
  	 add_column :hsn_codes, :code_type, :string
  end
end
