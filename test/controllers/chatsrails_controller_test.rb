require "test_helper"

class ChatsrailsControllerTest < ActionDispatch::IntegrationTest
  test "should get generate" do
    get chatsrails_generate_url
    assert_response :success
  end

  test "should get controller" do
    get chatsrails_controller_url
    assert_response :success
  end

  test "should get Chats" do
    get chatsrails_Chats_url
    assert_response :success
  end
end
