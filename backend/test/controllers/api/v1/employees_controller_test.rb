require "test_helper"

class Api::V1::EmployeesControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get "/api/v1/employees"
    assert_response :unauthorized
  end

  test "filters and paginates employees" do
    3.times do |index|
      employee = create_employee(employee_code: format("EMP%05d", 100 + index), email: "person#{index}@example.com")
      employee.salary_records.create!(annual_salary: 900_000, currency: "INR", effective_from: Date.current.beginning_of_year)
    end

    get "/api/v1/employees", params: { q: "EMP00100", page: 1, per_page: 1 }, headers: auth_headers
    assert_response :success
    body = response.parsed_body
    assert_equal "EMP00100", body.dig("data", 0, "employee_code")
    assert_equal 1, body.dig("pagination", "per_page")
  end


  test "creates an employee with an opening salary and audit events" do
    payload = {
      employee: { employee_code: "EMP98765", first_name: "Avery", last_name: "Rivera",
                  email: "avery.rivera@example.com", country_code: "IN", department: "People",
                  job_title: "People Partner", status: "active", hire_date: "2025-01-01" },
      salary: { annual_salary: 1_250_000, currency: "INR", effective_from: "2025-01-01" }
    }

    assert_difference -> { Employee.count }, 1 do
      assert_difference -> { SalaryRecord.count }, 1 do
        assert_difference -> { AuditEvent.count }, 2 do
          post "/api/v1/employees", params: payload, headers: auth_headers
        end
      end
    end
    assert_response :created
    assert_equal "EMP98765", response.parsed_body["employee_code"]
  end

  test "caps page size at 100" do
    get "/api/v1/employees", params: { per_page: 500 }, headers: auth_headers
    assert_response :success
    assert_equal 100, response.parsed_body.dig("pagination", "per_page")
  end
end
