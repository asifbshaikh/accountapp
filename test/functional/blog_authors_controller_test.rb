require 'test_helper'

class BlogAuthorsControllerTest < ActionController::TestCase
  setup do
    @blog_author = blog_authors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:blog_authors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create blog_author" do
    assert_difference('BlogAuthor.count') do
      post :create, :blog_author => @blog_author.attributes
    end

    assert_redirected_to blog_author_path(assigns(:blog_author))
  end

  test "should show blog_author" do
    get :show, :id => @blog_author.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @blog_author.to_param
    assert_response :success
  end

  test "should update blog_author" do
    put :update, :id => @blog_author.to_param, :blog_author => @blog_author.attributes
    assert_redirected_to blog_author_path(assigns(:blog_author))
  end

  test "should destroy blog_author" do
    assert_difference('BlogAuthor.count', -1) do
      delete :destroy, :id => @blog_author.to_param
    end

    assert_redirected_to blog_authors_path
  end
end
