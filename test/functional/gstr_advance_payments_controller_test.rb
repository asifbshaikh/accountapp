require 'test_helper'

class GstrAdvancePaymentsControllerTest < ActionController::TestCase
  setup do
    @gstr_advance_payment = gstr_advance_payments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gstr_advance_payments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gstr_advance_payment" do
    assert_difference('GstrAdvancePayment.count') do
      post :create, gstr_advance_payment: @gstr_advance_payment.attributes
    end

    assert_redirected_to gstr_advance_payment_path(assigns(:gstr_advance_payment))
  end

  test "should show gstr_advance_payment" do
    get :show, id: @gstr_advance_payment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gstr_advance_payment.to_param
    assert_response :success
  end

  test "should update gstr_advance_payment" do
    put :update, id: @gstr_advance_payment.to_param, gstr_advance_payment: @gstr_advance_payment.attributes
    assert_redirected_to gstr_advance_payment_path(assigns(:gstr_advance_payment))
  end

  test "should destroy gstr_advance_payment" do
    assert_difference('GstrAdvancePayment.count', -1) do
      delete :destroy, id: @gstr_advance_payment.to_param
    end

    assert_redirected_to gstr_advance_payments_path
  end
end
