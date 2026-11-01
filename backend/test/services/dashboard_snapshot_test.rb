require "test_helper"

class DashboardSnapshotTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    @employee = Employee.create!(employee_code: "EMP99991", first_name: "Ada", last_name: "Lovelace",
      email: "ada@example.test", country_code: "GB", department: "Engineering", job_title: "Engineer",
      status: "active", hire_date: Date.new(2020, 1, 1))
    @employee.salary_records.create!(annual_salary: 100_000, currency: "GBP", effective_from: Date.current - 1.year)
  end

  test "groups payroll by currency and counts employees without cross-currency conversion" do
    snapshot = DashboardSnapshot.new.call
    gbp = snapshot.fetch(:payroll_by_currency).find { |row| row[:currency] == "GBP" }

    assert_equal 100_000.0, gbp.fetch(:annual_total)
    assert_equal 1, gbp.fetch(:employee_count)
    assert_equal 1, snapshot.fetch(:countries_count)
  end

  test "caches dashboard snapshots and expires them explicitly" do
    first = DashboardSnapshot.fetch
    Rails.cache.write(DashboardSnapshot::CACHE_KEY, { stale: true }, expires_in: 1.minute)
    assert_equal({ stale: true }, DashboardSnapshot.fetch)

    DashboardSnapshot.expire!
    refute_equal({ stale: true }, DashboardSnapshot.fetch)
    assert_equal first.fetch(:employee_count), DashboardSnapshot.fetch.fetch(:employee_count)
  end
end
