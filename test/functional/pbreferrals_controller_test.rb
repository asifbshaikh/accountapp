require 'test_helper'

class PbreferralsControllerTest < ActionController::TestCase
  setup do
    @pbreferral = pbreferrals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pbreferrals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pbreferral" do
    assert_difference('Pbreferral.count') do
      post :create, :pbreferral => @pbreferral.attributes
    end

    assert_redirected_to pbreferral_path(assigns(:pbreferral))
  end

  test "should show pbreferral" do
    get :show, :id => @pbreferral.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @pbreferral.to_param
    assert_response :success
  end

  test "should update pbreferral" do
    put :update, :id => @pbreferral.to_param, :pbreferral => @pbreferral.attributes
    assert_redirected_to pbreferral_path(assigns(:pbreferral))
  end

  test "should destroy pbreferral" do
    assert_difference('Pbreferral.count', -1) do
      delete :destroy, :id => @pbreferral.to_param
    end

    assert_redirected_to pbreferrals_path
  end
end
