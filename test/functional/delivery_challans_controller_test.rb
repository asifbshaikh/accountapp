require 'test_helper'

class DeliveryChallansControllerTest < ActionController::TestCase
  setup do
    @delivery_challan = delivery_challans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:delivery_challans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create delivery_challan" do
    assert_difference('DeliveryChallan.count') do
      post :create, :delivery_challan => @delivery_challan.attributes
    end

    assert_redirected_to delivery_challan_path(assigns(:delivery_challan))
  end

  test "should show delivery_challan" do
    get :show, :id => @delivery_challan.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @delivery_challan.to_param
    assert_response :success
  end

  test "should update delivery_challan" do
    put :update, :id => @delivery_challan.to_param, :delivery_challan => @delivery_challan.attributes
    assert_redirected_to delivery_challan_path(assigns(:delivery_challan))
  end

  test "should destroy delivery_challan" do
    assert_difference('DeliveryChallan.count', -1) do
      delete :destroy, :id => @delivery_challan.to_param
    end

    assert_redirected_to delivery_challans_path
  end
end
