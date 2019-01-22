require 'test_helper'

class GstDebitNotesControllerTest < ActionController::TestCase
  setup do
    @gst_debit_note = gst_debit_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gst_debit_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gst_debit_note" do
    assert_difference('GstDebitNote.count') do
      post :create, gst_debit_note: @gst_debit_note.attributes
    end

    assert_redirected_to gst_debit_note_path(assigns(:gst_debit_note))
  end

  test "should show gst_debit_note" do
    get :show, id: @gst_debit_note.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gst_debit_note.to_param
    assert_response :success
  end

  test "should update gst_debit_note" do
    put :update, id: @gst_debit_note.to_param, gst_debit_note: @gst_debit_note.attributes
    assert_redirected_to gst_debit_note_path(assigns(:gst_debit_note))
  end

  test "should destroy gst_debit_note" do
    assert_difference('GstDebitNote.count', -1) do
      delete :destroy, id: @gst_debit_note.to_param
    end

    assert_redirected_to gst_debit_notes_path
  end
end
