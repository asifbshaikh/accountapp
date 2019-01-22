require 'test_helper'

class CustomerImportsControllerTest < ActionController::TestCase
  setup do
    @customer_import = customer_imports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:customer_imports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create customer_import" do
    assert_difference('CustomerImport.count') do
      post :create, :customer_import => @customer_import.attributes
    end

    assert_redirected_to customer_import_path(assigns(:customer_import))
  end

  test "should show customer_import" do
    get :show, :id => @customer_import.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @customer_import.to_param
    assert_response :success
  end

  test "should update customer_import" do
    put :update, :id => @customer_import.to_param, :customer_import => @customer_import.attributes
    assert_redirected_to customer_import_path(assigns(:customer_import))
  end

  test "should destroy customer_import" do
    assert_difference('CustomerImport.count', -1) do
      delete :destroy, :id => @customer_import.to_param
    end

    assert_redirected_to customer_imports_path
  end
end
