require 'test_helper'

class VoucherSettingsControllerTest < ActionController::TestCase
  setup do
    @voucher_setting = voucher_settings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:voucher_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create voucher_setting" do
    assert_difference('VoucherSetting.count') do
      post :create, :voucher_setting => @voucher_setting.attributes
    end

    assert_redirected_to voucher_setting_path(assigns(:voucher_setting))
  end

  test "should show voucher_setting" do
    get :show, :id => @voucher_setting.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @voucher_setting.to_param
    assert_response :success
  end

  test "should update voucher_setting" do
    put :update, :id => @voucher_setting.to_param, :voucher_setting => @voucher_setting.attributes
    assert_redirected_to voucher_setting_path(assigns(:voucher_setting))
  end

  test "should destroy voucher_setting" do
    assert_difference('VoucherSetting.count', -1) do
      delete :destroy, :id => @voucher_setting.to_param
    end

    assert_redirected_to voucher_settings_path
  end
end
