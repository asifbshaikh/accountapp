class AddSalesTaxToCustomer < ActiveRecord::Migration

  def change
    add_column :customers, :sales_tax_no, :integer
    # add_column :customers, :product_pricing_level_id, :integer
    # add_column :customers, :country, :string
    # add_column :customers, :weekly_off, :string
    # add_column :customers, :open_time, :string, :limit => 10
    # add_column :customers, :close_time, :string, :limit => 10
    # add_column :customers, :bank_name, :string, :limit => 25
    # add_column :customers, :ifsc_code, :string, :limit => 25
    # add_column :customers, :micr_code, :string, :limit => 25
    # add_column :customers, :bsr_code, :string, :limit => 25
  end
end
