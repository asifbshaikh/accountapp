require 'test_helper'

class SalesOrderReportsControllerTest < ActionController::TestCase
  test "should get customer_wise_so" do
    get :customer_wise_so
    assert_response :success
  end

  test "should get product_wise_so" do
    get :product_wise_so
    assert_response :success
  end

end
