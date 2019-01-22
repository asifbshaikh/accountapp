require 'test_helper'

class LeaveCardsControllerTest < ActionController::TestCase
  setup do
    @leave_card = leave_cards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:leave_cards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create leave_card" do
    assert_difference('LeaveCard.count') do
      post :create, :leave_card => @leave_card.attributes
    end

    assert_redirected_to leave_card_path(assigns(:leave_card))
  end

  test "should show leave_card" do
    get :show, :id => @leave_card.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @leave_card.to_param
    assert_response :success
  end

  test "should update leave_card" do
    put :update, :id => @leave_card.to_param, :leave_card => @leave_card.attributes
    assert_redirected_to leave_card_path(assigns(:leave_card))
  end

  test "should destroy leave_card" do
    assert_difference('LeaveCard.count', -1) do
      delete :destroy, :id => @leave_card.to_param
    end

    assert_redirected_to leave_cards_path
  end
end
