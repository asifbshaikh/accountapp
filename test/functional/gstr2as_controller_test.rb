require 'test_helper'

class Gstr2asControllerTest < ActionController::TestCase
  setup do
    @gstr2a = gstr2as(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gstr2as)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gstr2a" do
    assert_difference('Gstr2a.count') do
      post :create, gstr2a: @gstr2a.attributes
    end

    assert_redirected_to gstr2a_path(assigns(:gstr2a))
  end

  test "should show gstr2a" do
    get :show, id: @gstr2a.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gstr2a.to_param
    assert_response :success
  end

  test "should update gstr2a" do
    put :update, id: @gstr2a.to_param, gstr2a: @gstr2a.attributes
    assert_redirected_to gstr2a_path(assigns(:gstr2a))
  end

  test "should destroy gstr2a" do
    assert_difference('Gstr2a.count', -1) do
      delete :destroy, id: @gstr2a.to_param
    end

    assert_redirected_to gstr2as_path
  end
end
