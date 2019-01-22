require 'test_helper'

class GstrAdvanceReceiptsControllerTest < ActionController::TestCase
  setup do
    @gstr_advance_receipt = gstr_advance_receipts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gstr_advance_receipts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gstr_advance_receipt" do
    assert_difference('GstrAdvanceReceipt.count') do
      post :create, gstr_advance_receipt: @gstr_advance_receipt.attributes
    end

    assert_redirected_to gstr_advance_receipt_path(assigns(:gstr_advance_receipt))
  end

  test "should show gstr_advance_receipt" do
    get :show, id: @gstr_advance_receipt.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gstr_advance_receipt.to_param
    assert_response :success
  end

  test "should update gstr_advance_receipt" do
    put :update, id: @gstr_advance_receipt.to_param, gstr_advance_receipt: @gstr_advance_receipt.attributes
    assert_redirected_to gstr_advance_receipt_path(assigns(:gstr_advance_receipt))
  end

  test "should destroy gstr_advance_receipt" do
    assert_difference('GstrAdvanceReceipt.count', -1) do
      delete :destroy, id: @gstr_advance_receipt.to_param
    end

    assert_redirected_to gstr_advance_receipts_path
  end
end
