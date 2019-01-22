require 'test_helper'

class PayrollSettingsControllerTest < ActionController::TestCase
  setup do
    @payroll_setting = payroll_settings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payroll_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payroll_setting" do
    assert_difference('PayrollSetting.count') do
      post :create, payroll_setting: @payroll_setting.attributes
    end

    assert_redirected_to payroll_setting_path(assigns(:payroll_setting))
  end

  test "should show payroll_setting" do
    get :show, id: @payroll_setting.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @payroll_setting.to_param
    assert_response :success
  end

  test "should update payroll_setting" do
    put :update, id: @payroll_setting.to_param, payroll_setting: @payroll_setting.attributes
    assert_redirected_to payroll_setting_path(assigns(:payroll_setting))
  end

  test "should destroy payroll_setting" do
    assert_difference('PayrollSetting.count', -1) do
      delete :destroy, id: @payroll_setting.to_param
    end

    assert_redirected_to payroll_settings_path
  end
end
