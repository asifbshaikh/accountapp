require 'test_helper'

class CustomFieldsControllerTest < ActionController::TestCase
  setup do
    @custom_field = custom_fields(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:custom_fields)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create custom_field" do
    assert_difference('CustomField.count') do
      post :create, :custom_field => @custom_field.attributes
    end

    assert_redirected_to custom_field_path(assigns(:custom_field))
  end

  test "should show custom_field" do
    get :show, :id => @custom_field.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @custom_field.to_param
    assert_response :success
  end

  test "should update custom_field" do
    put :update, :id => @custom_field.to_param, :custom_field => @custom_field.attributes
    assert_redirected_to custom_field_path(assigns(:custom_field))
  end

  test "should destroy custom_field" do
    assert_difference('CustomField.count', -1) do
      delete :destroy, :id => @custom_field.to_param
    end

    assert_redirected_to custom_fields_path
  end
end
