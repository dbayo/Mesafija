require 'test_helper'

class ApiMesafijasControllerTest < ActionController::TestCase
  setup do
    @api_mesafija = api_mesafijas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:api_mesafijas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create api_mesafija" do
    assert_difference('ApiMesafija.count') do
      post :create, api_mesafija: {  }
    end

    assert_redirected_to api_mesafija_path(assigns(:api_mesafija))
  end

  test "should show api_mesafija" do
    get :show, id: @api_mesafija
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @api_mesafija
    assert_response :success
  end

  test "should update api_mesafija" do
    patch :update, id: @api_mesafija, api_mesafija: {  }
    assert_redirected_to api_mesafija_path(assigns(:api_mesafija))
  end

  test "should destroy api_mesafija" do
    assert_difference('ApiMesafija.count', -1) do
      delete :destroy, id: @api_mesafija
    end

    assert_redirected_to api_mesafijas_path
  end
end
