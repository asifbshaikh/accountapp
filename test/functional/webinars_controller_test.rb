require 'test_helper'

class WebinarsControllerTest < ActionController::TestCase
  setup do
    @webinar = webinars(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:webinars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create webinar" do
    assert_difference('Webinar.count') do
      post :create, :webinar => @webinar.attributes
    end

    assert_redirected_to webinar_path(assigns(:webinar))
  end

  test "should show webinar" do
    get :show, :id => @webinar.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @webinar.to_param
    assert_response :success
  end

  test "should update webinar" do
    put :update, :id => @webinar.to_param, :webinar => @webinar.attributes
    assert_redirected_to webinar_path(assigns(:webinar))
  end

  test "should destroy webinar" do
    assert_difference('Webinar.count', -1) do
      delete :destroy, :id => @webinar.to_param
    end

    assert_redirected_to webinars_path
  end
end
