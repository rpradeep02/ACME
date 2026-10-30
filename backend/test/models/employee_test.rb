require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  test "normalizes email and country code" do
    employee = create_employee(email: "  PERSON@Example.com ", country_code: "in")
    assert_equal "person@example.com", employee.email
    assert_equal "IN", employee.country_code
  end

  test "rejects unsupported country and duplicate employee code" do
    employee = Employee.new(employee_code: "BAD", first_name: "A", last_name: "B", email: "a@b.com",
      country_code: "ZZZ", department: "Ops", job_title: "Lead", status: "active", hire_date: Date.current)
    refute employee.valid?
    assert_includes employee.errors.attribute_names, :employee_code
    assert_includes employee.errors.attribute_names, :country_code
  end
end
