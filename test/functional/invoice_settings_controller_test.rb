require 'test_helper'

class InvoiceSettingsControllerTest < ActionController::TestCase
  setup do
    @invoice_setting = invoice_settings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_setting" do
    assert_difference('InvoiceSetting.count') do
      post :create, :invoice_setting => @invoice_setting.attributes
    end

    assert_redirected_to invoice_setting_path(assigns(:invoice_setting))
  end

  test "should show invoice_setting" do
    get :show, :id => @invoice_setting.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @invoice_setting.to_param
    assert_response :success
  end

  test "should update invoice_setting" do
    put :update, :id => @invoice_setting.to_param, :invoice_setting => @invoice_setting.attributes
    assert_redirected_to invoice_setting_path(assigns(:invoice_setting))
  end

  test "should destroy invoice_setting" do
    assert_difference('InvoiceSetting.count', -1) do
      delete :destroy, :id => @invoice_setting.to_param
    end

    assert_redirected_to invoice_settings_path
  end
end
