require 'test_helper'

class StockTransferVouchersControllerTest < ActionController::TestCase
  setup do
    @stock_transfer_voucher = stock_transfer_vouchers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stock_transfer_vouchers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stock_transfer_voucher" do
    assert_difference('StockTransferVoucher.count') do
      post :create, :stock_transfer_voucher => @stock_transfer_voucher.attributes
    end

    assert_redirected_to stock_transfer_voucher_path(assigns(:stock_transfer_voucher))
  end

  test "should show stock_transfer_voucher" do
    get :show, :id => @stock_transfer_voucher.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stock_transfer_voucher.to_param
    assert_response :success
  end

  test "should update stock_transfer_voucher" do
    put :update, :id => @stock_transfer_voucher.to_param, :stock_transfer_voucher => @stock_transfer_voucher.attributes
    assert_redirected_to stock_transfer_voucher_path(assigns(:stock_transfer_voucher))
  end

  test "should destroy stock_transfer_voucher" do
    assert_difference('StockTransferVoucher.count', -1) do
      delete :destroy, :id => @stock_transfer_voucher.to_param
    end

    assert_redirected_to stock_transfer_vouchers_path
  end
end
