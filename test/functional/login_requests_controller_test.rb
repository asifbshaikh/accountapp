require 'test_helper'

class LoginRequestsControllerTest < ActionController::TestCase
  setup do
    @login_request = login_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:login_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create login_request" do
    assert_difference('LoginRequest.count') do
      post :create, login_request: @login_request.attributes
    end

    assert_redirected_to login_request_path(assigns(:login_request))
  end

  test "should show login_request" do
    get :show, id: @login_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @login_request.to_param
    assert_response :success
  end

  test "should update login_request" do
    put :update, id: @login_request.to_param, login_request: @login_request.attributes
    assert_redirected_to login_request_path(assigns(:login_request))
  end

  test "should destroy login_request" do
    assert_difference('LoginRequest.count', -1) do
      delete :destroy, id: @login_request.to_param
    end

    assert_redirected_to login_requests_path
  end
end
