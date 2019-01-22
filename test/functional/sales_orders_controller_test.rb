require 'test_helper'

class SalesOrdersControllerTest < ActionController::TestCase
  setup do
    @sales_order = sales_orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales_orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sales_order" do
    assert_difference('SalesOrder.count') do
      post :create, :sales_order => @sales_order.attributes
    end

    assert_redirected_to sales_order_path(assigns(:sales_order))
  end

  test "should show sales_order" do
    get :show, :id => @sales_order.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @sales_order.to_param
    assert_response :success
  end

  test "should update sales_order" do
    put :update, :id => @sales_order.to_param, :sales_order => @sales_order.attributes
    assert_redirected_to sales_order_path(assigns(:sales_order))
  end

  test "should destroy sales_order" do
    assert_difference('SalesOrder.count', -1) do
      delete :destroy, :id => @sales_order.to_param
    end

    assert_redirected_to sales_orders_path
  end
end
