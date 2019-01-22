class ProcessPaymentsController < ApplicationController
  
 def index
    @company = Company.find(User.find(session[:current_user_id]).company_id)
    merchant_access_key = "MH09720FWD4YXANH8YCL"
    transaction_number = ""
    vanityUrl = "thenextwave"
    currency = "INR"
    state = @company.address.state
    city = @company.address.city
    address = @company.address.address_line1
    country = @company.address.country
    pincode = @company.address.postal_code
    first_name = @current_user.first_name
    last_name = @current_user.last_name
    email = @current_user.email
    amount = ""
    return_url = "https://profitbookshq.com/dashboard/index"
 end

end
