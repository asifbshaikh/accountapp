require 'test_helper'

class CompanyAssetsControllerTest < ActionController::TestCase
  setup do
    @company_asset = company_assets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:company_assets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company_asset" do
    assert_difference('CompanyAsset.count') do
      post :create, :company_asset => @company_asset.attributes
    end

    assert_redirected_to company_asset_path(assigns(:company_asset))
  end

  test "should show company_asset" do
    get :show, :id => @company_asset.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @company_asset.to_param
    assert_response :success
  end

  test "should update company_asset" do
    put :update, :id => @company_asset.to_param, :company_asset => @company_asset.attributes
    assert_redirected_to company_asset_path(assigns(:company_asset))
  end

  test "should destroy company_asset" do
    assert_difference('CompanyAsset.count', -1) do
      delete :destroy, :id => @company_asset.to_param
    end

    assert_redirected_to company_assets_path
  end
end
