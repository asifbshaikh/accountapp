require 'test_helper'

class StockWastageLineItemsControllerTest < ActionController::TestCase
  setup do
    @stock_wastage_line_item = stock_wastage_line_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stock_wastage_line_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stock_wastage_line_item" do
    assert_difference('StockWastageLineItem.count') do
      post :create, :stock_wastage_line_item => @stock_wastage_line_item.attributes
    end

    assert_redirected_to stock_wastage_line_item_path(assigns(:stock_wastage_line_item))
  end

  test "should show stock_wastage_line_item" do
    get :show, :id => @stock_wastage_line_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stock_wastage_line_item.to_param
    assert_response :success
  end

  test "should update stock_wastage_line_item" do
    put :update, :id => @stock_wastage_line_item.to_param, :stock_wastage_line_item => @stock_wastage_line_item.attributes
    assert_redirected_to stock_wastage_line_item_path(assigns(:stock_wastage_line_item))
  end

  test "should destroy stock_wastage_line_item" do
    assert_difference('StockWastageLineItem.count', -1) do
      delete :destroy, :id => @stock_wastage_line_item.to_param
    end

    assert_redirected_to stock_wastage_line_items_path
  end
end
