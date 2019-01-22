require 'test_helper'

class PurchaseAttachmentsControllerTest < ActionController::TestCase
  setup do
    @purchase_attachment = purchase_attachments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_attachments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_attachment" do
    assert_difference('PurchaseAttachment.count') do
      post :create, purchase_attachment: @purchase_attachment.attributes
    end

    assert_redirected_to purchase_attachment_path(assigns(:purchase_attachment))
  end

  test "should show purchase_attachment" do
    get :show, id: @purchase_attachment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_attachment.to_param
    assert_response :success
  end

  test "should update purchase_attachment" do
    put :update, id: @purchase_attachment.to_param, purchase_attachment: @purchase_attachment.attributes
    assert_redirected_to purchase_attachment_path(assigns(:purchase_attachment))
  end

  test "should destroy purchase_attachment" do
    assert_difference('PurchaseAttachment.count', -1) do
      delete :destroy, id: @purchase_attachment.to_param
    end

    assert_redirected_to purchase_attachments_path
  end
end
