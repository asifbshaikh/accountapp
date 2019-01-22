require 'test_helper'

class StockWastageVouchersControllerTest < ActionController::TestCase
  setup do
    @stock_wastage_voucher = stock_wastage_vouchers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stock_wastage_vouchers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stock_wastage_voucher" do
    assert_difference('StockWastageVoucher.count') do
      post :create, :stock_wastage_voucher => @stock_wastage_voucher.attributes
    end

    assert_redirected_to stock_wastage_voucher_path(assigns(:stock_wastage_voucher))
  end

  test "should show stock_wastage_voucher" do
    get :show, :id => @stock_wastage_voucher.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stock_wastage_voucher.to_param
    assert_response :success
  end

  test "should update stock_wastage_voucher" do
    put :update, :id => @stock_wastage_voucher.to_param, :stock_wastage_voucher => @stock_wastage_voucher.attributes
    assert_redirected_to stock_wastage_voucher_path(assigns(:stock_wastage_voucher))
  end

  test "should destroy stock_wastage_voucher" do
    assert_difference('StockWastageVoucher.count', -1) do
      delete :destroy, :id => @stock_wastage_voucher.to_param
    end

    assert_redirected_to stock_wastage_vouchers_path
  end
end
