require 'test_helper'

class VendorImportsControllerTest < ActionController::TestCase
  setup do
    @vendor_import = vendor_imports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vendor_imports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vendor_import" do
    assert_difference('VendorImport.count') do
      post :create, :vendor_import => @vendor_import.attributes
    end

    assert_redirected_to vendor_import_path(assigns(:vendor_import))
  end

  test "should show vendor_import" do
    get :show, :id => @vendor_import.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @vendor_import.to_param
    assert_response :success
  end

  test "should update vendor_import" do
    put :update, :id => @vendor_import.to_param, :vendor_import => @vendor_import.attributes
    assert_redirected_to vendor_import_path(assigns(:vendor_import))
  end

  test "should destroy vendor_import" do
    assert_difference('VendorImport.count', -1) do
      delete :destroy, :id => @vendor_import.to_param
    end

    assert_redirected_to vendor_imports_path
  end
end
