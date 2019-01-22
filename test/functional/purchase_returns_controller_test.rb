require 'test_helper'

class PurchaseReturnsControllerTest < ActionController::TestCase
  setup do
    @purchase_return = purchase_returns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_returns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_return" do
    assert_difference('PurchaseReturn.count') do
      post :create, :purchase_return => @purchase_return.attributes
    end

    assert_redirected_to purchase_return_path(assigns(:purchase_return))
  end

  test "should show purchase_return" do
    get :show, :id => @purchase_return.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @purchase_return.to_param
    assert_response :success
  end

  test "should update purchase_return" do
    put :update, :id => @purchase_return.to_param, :purchase_return => @purchase_return.attributes
    assert_redirected_to purchase_return_path(assigns(:purchase_return))
  end

  test "should destroy purchase_return" do
    assert_difference('PurchaseReturn.count', -1) do
      delete :destroy, :id => @purchase_return.to_param
    end

    assert_redirected_to purchase_returns_path
  end
end
