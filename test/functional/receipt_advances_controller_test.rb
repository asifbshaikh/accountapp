require 'test_helper'

class ReceiptAdvancesControllerTest < ActionController::TestCase
  setup do
    @receipt_advance = receipt_advances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:receipt_advances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create receipt_advance" do
    assert_difference('ReceiptAdvance.count') do
      post :create, receipt_advance: @receipt_advance.attributes
    end

    assert_redirected_to receipt_advance_path(assigns(:receipt_advance))
  end

  test "should show receipt_advance" do
    get :show, id: @receipt_advance.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @receipt_advance.to_param
    assert_response :success
  end

  test "should update receipt_advance" do
    put :update, id: @receipt_advance.to_param, receipt_advance: @receipt_advance.attributes
    assert_redirected_to receipt_advance_path(assigns(:receipt_advance))
  end

  test "should destroy receipt_advance" do
    assert_difference('ReceiptAdvance.count', -1) do
      delete :destroy, id: @receipt_advance.to_param
    end

    assert_redirected_to receipt_advances_path
  end
end
