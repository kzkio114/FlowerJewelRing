require "test_helper"

class GiftsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get gifts_index_url
    assert_response :success
  end

  test "should get show" do
    get gifts_show_url
    assert_response :success
  end

  test "should get new" do
    get gifts_new_url
    assert_response :success
  end

  test "should get edit" do
    get gifts_edit_url
    assert_response :success
  end
end
