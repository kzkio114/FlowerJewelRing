require "test_helper"

class GroupChatMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get group_chat_messages_create_url
    assert_response :success
  end

  test "should get destroy" do
    get group_chat_messages_destroy_url
    assert_response :success
  end
end
