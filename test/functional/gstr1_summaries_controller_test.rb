require 'test_helper'

class Gstr1SummariesControllerTest < ActionController::TestCase
  setup do
    @gstr1_summary = gstr1_summaries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gstr1_summaries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gstr1_summary" do
    assert_difference('Gstr1Summary.count') do
      post :create, gstr1_summary: @gstr1_summary.attributes
    end

    assert_redirected_to gstr1_summary_path(assigns(:gstr1_summary))
  end

  test "should show gstr1_summary" do
    get :show, id: @gstr1_summary.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gstr1_summary.to_param
    assert_response :success
  end

  test "should update gstr1_summary" do
    put :update, id: @gstr1_summary.to_param, gstr1_summary: @gstr1_summary.attributes
    assert_redirected_to gstr1_summary_path(assigns(:gstr1_summary))
  end

  test "should destroy gstr1_summary" do
    assert_difference('Gstr1Summary.count', -1) do
      delete :destroy, id: @gstr1_summary.to_param
    end

    assert_redirected_to gstr1_summaries_path
  end
end
