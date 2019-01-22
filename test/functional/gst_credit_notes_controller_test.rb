require 'test_helper'

class GstCreditNotesControllerTest < ActionController::TestCase
  setup do
    @gst_credit_note = gst_credit_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gst_credit_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gst_credit_note" do
    assert_difference('GstCreditNote.count') do
      post :create, gst_credit_note: @gst_credit_note.attributes
    end

    assert_redirected_to gst_credit_note_path(assigns(:gst_credit_note))
  end

  test "should show gst_credit_note" do
    get :show, id: @gst_credit_note.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gst_credit_note.to_param
    assert_response :success
  end

  test "should update gst_credit_note" do
    put :update, id: @gst_credit_note.to_param, gst_credit_note: @gst_credit_note.attributes
    assert_redirected_to gst_credit_note_path(assigns(:gst_credit_note))
  end

  test "should destroy gst_credit_note" do
    assert_difference('GstCreditNote.count', -1) do
      delete :destroy, id: @gst_credit_note.to_param
    end

    assert_redirected_to gst_credit_notes_path
  end
end
