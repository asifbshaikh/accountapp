require 'test_helper'

class WarehouseWiseStockControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
