require 'test_helper'

class Gstr3bReportsControllerTest < ActionController::TestCase
  setup do
    @gstr3b_report = gstr3b_reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gstr3b_reports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gstr3b_report" do
    assert_difference('Gstr3bReport.count') do
      post :create, gstr3b_report: @gstr3b_report.attributes
    end

    assert_redirected_to gstr3b_report_path(assigns(:gstr3b_report))
  end

  test "should show gstr3b_report" do
    get :show, id: @gstr3b_report.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gstr3b_report.to_param
    assert_response :success
  end

  test "should update gstr3b_report" do
    put :update, id: @gstr3b_report.to_param, gstr3b_report: @gstr3b_report.attributes
    assert_redirected_to gstr3b_report_path(assigns(:gstr3b_report))
  end

  test "should destroy gstr3b_report" do
    assert_difference('Gstr3bReport.count', -1) do
      delete :destroy, id: @gstr3b_report.to_param
    end

    assert_redirected_to gstr3b_reports_path
  end
end
