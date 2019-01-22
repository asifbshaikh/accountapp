require 'test_helper'

class PurchaseReturnLineItemsControllerTest < ActionController::TestCase
  setup do
    @purchase_return_line_item = purchase_return_line_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_return_line_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_return_line_item" do
    assert_difference('PurchaseReturnLineItem.count') do
      post :create, :purchase_return_line_item => @purchase_return_line_item.attributes
    end

    assert_redirected_to purchase_return_line_item_path(assigns(:purchase_return_line_item))
  end

  test "should show purchase_return_line_item" do
    get :show, :id => @purchase_return_line_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @purchase_return_line_item.to_param
    assert_response :success
  end

  test "should update purchase_return_line_item" do
    put :update, :id => @purchase_return_line_item.to_param, :purchase_return_line_item => @purchase_return_line_item.attributes
    assert_redirected_to purchase_return_line_item_path(assigns(:purchase_return_line_item))
  end

  test "should destroy purchase_return_line_item" do
    assert_difference('PurchaseReturnLineItem.count', -1) do
      delete :destroy, :id => @purchase_return_line_item.to_param
    end

    assert_redirected_to purchase_return_line_items_path
  end
end
