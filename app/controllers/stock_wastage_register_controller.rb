class StockWastageRegisterController < ApplicationController
 def index
    @menu = "Inventory Reports"
    @page_name = "Stock wastage register"
    @stock_wastage_vouchers = StockWastageVoucher.get_wastage_record(params, @company, @current_user, @financial_year)
    @custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(@company.id, "StockWastageVoucher", true)
    prawnto :filename => "stock_wastage_register.pdf"
  end
end
