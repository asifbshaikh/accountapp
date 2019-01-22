require 'test_helper'

class InvoiceReturnsControllerTest < ActionController::TestCase
  setup do
    @invoice_return = invoice_returns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_returns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_return" do
    assert_difference('InvoiceReturn.count') do
      post :create, :invoice_return => @invoice_return.attributes
    end

    assert_redirected_to invoice_return_path(assigns(:invoice_return))
  end

  test "should show invoice_return" do
    get :show, :id => @invoice_return.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @invoice_return.to_param
    assert_response :success
  end

  test "should update invoice_return" do
    put :update, :id => @invoice_return.to_param, :invoice_return => @invoice_return.attributes
    assert_redirected_to invoice_return_path(assigns(:invoice_return))
  end

  test "should destroy invoice_return" do
    assert_difference('InvoiceReturn.count', -1) do
      delete :destroy, :id => @invoice_return.to_param
    end

    assert_redirected_to invoice_returns_path
  end
end
