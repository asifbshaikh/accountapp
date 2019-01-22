require 'test_helper'

class PurchaseAdvancesControllerTest < ActionController::TestCase
  setup do
    @purchase_advance = purchase_advances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_advances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_advance" do
    assert_difference('PurchaseAdvance.count') do
      post :create, purchase_advance: @purchase_advance.attributes
    end

    assert_redirected_to purchase_advance_path(assigns(:purchase_advance))
  end

  test "should show purchase_advance" do
    get :show, id: @purchase_advance.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_advance.to_param
    assert_response :success
  end

  test "should update purchase_advance" do
    put :update, id: @purchase_advance.to_param, purchase_advance: @purchase_advance.attributes
    assert_redirected_to purchase_advance_path(assigns(:purchase_advance))
  end

  test "should destroy purchase_advance" do
    assert_difference('PurchaseAdvance.count', -1) do
      delete :destroy, id: @purchase_advance.to_param
    end

    assert_redirected_to purchase_advances_path
  end
end
