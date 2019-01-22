require 'test_helper'

class GstReturnsControllerTest < ActionController::TestCase
  setup do
    @gst_return = gst_returns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gst_returns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gst_return" do
    assert_difference('GstReturn.count') do
      post :create, gst_return: @gst_return.attributes
    end

    assert_redirected_to gst_return_path(assigns(:gst_return))
  end

  test "should show gst_return" do
    get :show, id: @gst_return.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gst_return.to_param
    assert_response :success
  end

  test "should update gst_return" do
    put :update, id: @gst_return.to_param, gst_return: @gst_return.attributes
    assert_redirected_to gst_return_path(assigns(:gst_return))
  end

  test "should destroy gst_return" do
    assert_difference('GstReturn.count', -1) do
      delete :destroy, id: @gst_return.to_param
    end

    assert_redirected_to gst_returns_path
  end
end
