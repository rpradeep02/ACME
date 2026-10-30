require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "returns a token for valid HR credentials" do
    user = User.create!(email: "hr-login@acme.example", password: "Password123!", role: "hr_manager")
    post "/api/v1/session", params: { email: user.email, password: "Password123!" }
    assert_response :success
    assert response.parsed_body["token"].present?
  end

  test "does not disclose whether the email exists" do
    post "/api/v1/session", params: { email: "unknown@example.com", password: "bad" }
    assert_response :unauthorized
    assert_equal "Invalid email or password", response.parsed_body["error"]
  end
end
