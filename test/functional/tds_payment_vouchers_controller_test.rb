require 'test_helper'

class TdsPaymentVouchersControllerTest < ActionController::TestCase
  setup do
    @tds_payment_voucher = tds_payment_vouchers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tds_payment_vouchers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tds_payment_voucher" do
    assert_difference('TdsPaymentVoucher.count') do
      post :create, :tds_payment_voucher => @tds_payment_voucher.attributes
    end

    assert_redirected_to tds_payment_voucher_path(assigns(:tds_payment_voucher))
  end

  test "should show tds_payment_voucher" do
    get :show, :id => @tds_payment_voucher.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @tds_payment_voucher.to_param
    assert_response :success
  end

  test "should update tds_payment_voucher" do
    put :update, :id => @tds_payment_voucher.to_param, :tds_payment_voucher => @tds_payment_voucher.attributes
    assert_redirected_to tds_payment_voucher_path(assigns(:tds_payment_voucher))
  end

  test "should destroy tds_payment_voucher" do
    assert_difference('TdsPaymentVoucher.count', -1) do
      delete :destroy, :id => @tds_payment_voucher.to_param
    end

    assert_redirected_to tds_payment_vouchers_path
  end
end
