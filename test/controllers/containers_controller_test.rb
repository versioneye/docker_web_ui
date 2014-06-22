require 'test_helper'

class ContainersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get start" do
    get :start
    assert_response :success
  end

  test "should get stop" do
    get :stop
    assert_response :success
  end

  test "should get kill" do
    get :kill
    assert_response :success
  end

  test "should get remove" do
    get :remove
    assert_response :success
  end

end
