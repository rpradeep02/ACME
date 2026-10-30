require "test_helper"

class SalaryRecordsCreateTest < ActiveSupport::TestCase
  test "closes the prior open period one day before the new salary starts" do
    employee = create_employee
    prior = employee.salary_records.create!(annual_salary: 1_000_000, currency: "INR", effective_from: Date.new(2024, 1, 1))
    result = SalaryRecords::Create.new(employee: employee,
      attributes: { annual_salary: 1_200_000, currency: "INR", effective_from: Date.new(2025, 4, 1) }, actor: hr_user).call

    assert result.success?, result.errors.inspect
    assert_equal Date.new(2025, 3, 31), prior.reload.effective_to
    assert_equal Date.new(2025, 4, 1), result.record.effective_from
    assert_equal 1, AuditEvent.where(action: "salary_created", auditable: result.record).count
  end

  test "rejects an overlapping future salary period" do
    employee = create_employee
    employee.salary_records.create!(annual_salary: 1_000_000, currency: "INR", effective_from: Date.new(2025, 1, 1), effective_to: Date.new(2025, 12, 31))
    result = SalaryRecords::Create.new(employee: employee,
      attributes: { annual_salary: 1_100_000, currency: "INR", effective_from: Date.new(2025, 6, 1) }, actor: hr_user).call

    refute result.success?
    assert_match(/overlaps/, result.errors.join(" "))
  end
end
