require "test_helper"

class Api::V1::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "returns payroll separated by currency" do
    employee_in = create_employee
    employee_in.salary_records.create!(annual_salary: 1_000_000, currency: "INR", effective_from: Date.current.beginning_of_year)
    employee_us = create_employee(employee_code: "EMP54321", email: "us@example.com", country_code: "US")
    employee_us.salary_records.create!(annual_salary: 100_000, currency: "USD", effective_from: Date.current.beginning_of_year)
    terminated = create_employee(employee_code: "EMP54322", email: "terminated@example.com", country_code: "US", status: "terminated")
    terminated.salary_records.create!(annual_salary: 900_000, currency: "USD", effective_from: Date.current.beginning_of_year)

    get "/api/v1/dashboard", headers: auth_headers
    assert_response :success
    rows = response.parsed_body.fetch("payroll_by_currency")
    assert_equal %w[INR USD], rows.map { |row| row["currency"] }.sort
    assert_equal 100_000, rows.find { |row| row["currency"] == "USD" }["annual_total"]
  end
end
