require 'test_helper'

class GainOrLossReportControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get currency_wise" do
    get :currency_wise
    assert_response :success
  end

  test "should get customer_wise" do
    get :customer_wise
    assert_response :success
  end

end
