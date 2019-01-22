require 'test_helper'

class InventoryStatementsControllerTest < ActionController::TestCase
  test "should get stock_statement" do
    get :stock_statement
    assert_response :success
  end

  test "should get product_statement" do
    get :product_statement
    assert_response :success
  end

end
