class AddCompanyToCustomerImports < ActiveRecord::Migration
  def change
    add_column :customer_imports, :company_id, :integer, :null => false
  end
  
end
