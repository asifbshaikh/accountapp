require 'test_helper'

class StockMovementControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
