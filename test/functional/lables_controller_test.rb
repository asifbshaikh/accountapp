require 'test_helper'

class LablesControllerTest < ActionController::TestCase
  setup do
    @lable = lables(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lables)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lable" do
    assert_difference('Lable.count') do
      post :create, :lable => @lable.attributes
    end

    assert_redirected_to lable_path(assigns(:lable))
  end

  test "should show lable" do
    get :show, :id => @lable.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @lable.to_param
    assert_response :success
  end

  test "should update lable" do
    put :update, :id => @lable.to_param, :lable => @lable.attributes
    assert_redirected_to lable_path(assigns(:lable))
  end

  test "should destroy lable" do
    assert_difference('Lable.count', -1) do
      delete :destroy, :id => @lable.to_param
    end

    assert_redirected_to lables_path
  end
end
