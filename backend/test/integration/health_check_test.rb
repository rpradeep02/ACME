require "test_helper"

class HealthCheckTest < ActionDispatch::IntegrationTest
  test "reports the API as healthy without authentication" do
    get "/up"

    assert_response :success
  end
end
