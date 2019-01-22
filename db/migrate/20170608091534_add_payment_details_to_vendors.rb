class AddPaymentDetailsToVendors < ActiveRecord::Migration
  def change
  	add_column :vendors, :payment_information, :string
  end
end
