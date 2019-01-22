require 'test_helper'

class InvoiceAttachmentsControllerTest < ActionController::TestCase
  setup do
    @invoice_attachment = invoice_attachments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_attachments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_attachment" do
    assert_difference('InvoiceAttachment.count') do
      post :create, invoice_attachment: @invoice_attachment.attributes
    end

    assert_redirected_to invoice_attachment_path(assigns(:invoice_attachment))
  end

  test "should show invoice_attachment" do
    get :show, id: @invoice_attachment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @invoice_attachment.to_param
    assert_response :success
  end

  test "should update invoice_attachment" do
    put :update, id: @invoice_attachment.to_param, invoice_attachment: @invoice_attachment.attributes
    assert_redirected_to invoice_attachment_path(assigns(:invoice_attachment))
  end

  test "should destroy invoice_attachment" do
    assert_difference('InvoiceAttachment.count', -1) do
      delete :destroy, id: @invoice_attachment.to_param
    end

    assert_redirected_to invoice_attachments_path
  end
end
