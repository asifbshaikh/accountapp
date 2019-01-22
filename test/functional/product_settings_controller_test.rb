require 'test_helper'

class ProductSettingsControllerTest < ActionController::TestCase
  setup do
    @product_setting = product_settings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product_setting" do
    assert_difference('ProductSetting.count') do
      post :create, :product_setting => @product_setting.attributes
    end

    assert_redirected_to product_setting_path(assigns(:product_setting))
  end

  test "should show product_setting" do
    get :show, :id => @product_setting.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @product_setting.to_param
    assert_response :success
  end

  test "should update product_setting" do
    put :update, :id => @product_setting.to_param, :product_setting => @product_setting.attributes
    assert_redirected_to product_setting_path(assigns(:product_setting))
  end

  test "should destroy product_setting" do
    assert_difference('ProductSetting.count', -1) do
      delete :destroy, :id => @product_setting.to_param
    end

    assert_redirected_to product_settings_path
  end
end
