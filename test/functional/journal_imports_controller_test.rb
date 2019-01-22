require 'test_helper'

class JournalImportsControllerTest < ActionController::TestCase
  setup do
    @journal_import = journal_imports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:journal_imports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create journal_import" do
    assert_difference('JournalImport.count') do
      post :create, :journal_import => @journal_import.attributes
    end

    assert_redirected_to journal_import_path(assigns(:journal_import))
  end

  test "should show journal_import" do
    get :show, :id => @journal_import.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @journal_import.to_param
    assert_response :success
  end

  test "should update journal_import" do
    put :update, :id => @journal_import.to_param, :journal_import => @journal_import.attributes
    assert_redirected_to journal_import_path(assigns(:journal_import))
  end

  test "should destroy journal_import" do
    assert_difference('JournalImport.count', -1) do
      delete :destroy, :id => @journal_import.to_param
    end

    assert_redirected_to journal_imports_path
  end
end
