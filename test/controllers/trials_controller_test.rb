require "test_helper"

class TrialsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trials_index_url
    assert_response :success
  end
end
