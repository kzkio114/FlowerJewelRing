require "test_helper"

class GroupChatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get group_chats_index_url
    assert_response :success
  end

  test "should get group_chat" do
    get group_chats_group_chat_url
    assert_response :success
  end

  test "should get new" do
    get group_chats_new_url
    assert_response :success
  end

  test "should get create" do
    get group_chats_create_url
    assert_response :success
  end

  test "should get edit" do
    get group_chats_edit_url
    assert_response :success
  end

  test "should get update" do
    get group_chats_update_url
    assert_response :success
  end

  test "should get destroy" do
    get group_chats_destroy_url
    assert_response :success
  end
end
