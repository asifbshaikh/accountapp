require 'test_helper'

class InventorySettingsControllerTest < ActionController::TestCase
  setup do
    @inventory_setting = inventory_settings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:inventory_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inventory_setting" do
    assert_difference('InventorySetting.count') do
      post :create, :inventory_setting => @inventory_setting.attributes
    end

    assert_redirected_to inventory_setting_path(assigns(:inventory_setting))
  end

  test "should show inventory_setting" do
    get :show, :id => @inventory_setting.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @inventory_setting.to_param
    assert_response :success
  end

  test "should update inventory_setting" do
    put :update, :id => @inventory_setting.to_param, :inventory_setting => @inventory_setting.attributes
    assert_redirected_to inventory_setting_path(assigns(:inventory_setting))
  end

  test "should destroy inventory_setting" do
    assert_difference('InventorySetting.count', -1) do
      delete :destroy, :id => @inventory_setting.to_param
    end

    assert_redirected_to inventory_settings_path
  end
end
