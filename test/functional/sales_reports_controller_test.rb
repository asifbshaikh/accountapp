require 'test_helper'

class SalesReportsControllerTest < ActionController::TestCase
  test "should get sales_by_customer" do
    get :sales_by_customer
    assert_response :success
  end

  test "should get sales_by_item" do
    get :sales_by_item
    assert_response :success
  end

end
