require "test_helper"

class SalaryRecordTest < ActiveSupport::TestCase
  test "validates currency, amount and effective period" do
    employee = create_employee
    record = employee.salary_records.new(annual_salary: -1, currency: "XXX", effective_from: Date.current,
                                         effective_to: Date.current - 1.day)
    refute record.valid?
    assert_includes record.errors.attribute_names, :annual_salary
    assert_includes record.errors.attribute_names, :currency
    assert_includes record.errors.attribute_names, :effective_to
  end

  test "current_on includes both interval boundaries" do
    employee = create_employee
    record = employee.salary_records.create!(annual_salary: 1_000_000, currency: "INR", effective_from: Date.new(2025, 1, 1), effective_to: Date.new(2025, 12, 31))
    assert_includes SalaryRecord.current_on(Date.new(2025, 1, 1)), record
    assert_includes SalaryRecord.current_on(Date.new(2025, 12, 31)), record
    refute_includes SalaryRecord.current_on(Date.new(2026, 1, 1)), record
  end
end
