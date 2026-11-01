class DashboardSnapshot
  CACHE_KEY = "dashboard:v1".freeze
  CACHE_TTL = 2.minutes

  def self.fetch = Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) { new.call }
  def self.refresh! = Rails.cache.write(CACHE_KEY, new.call, expires_in: CACHE_TTL)
  def self.expire! = Rails.cache.delete(CACHE_KEY)

  def call
    active_employees = Employee.where(status: "active")
    current_salaries = SalaryRecord.current_on.joins(:employee).where.not(employees: { status: "terminated" })
    payroll_totals = current_salaries.group(:currency).sum(:annual_salary)
    payroll_counts = current_salaries.group(:currency).count

    {
      employee_count: Employee.count,
      active_employee_count: active_employees.count,
      countries_count: Employee.distinct.count(:country_code),
      headcount_by_country: Employee.group(:country_code).order(:country_code).count.map { |code, count| { country_code: code, count: count } },
      payroll_by_currency: payroll_totals.map { |currency, amount| { currency: currency, annual_total: amount.to_f, employee_count: payroll_counts.fetch(currency, 0) } }.sort_by { |row| row[:currency] },
      departments: active_employees.group(:department).order(:department).count.map { |name, count| { department: name, count: count } }
    }
  end
end
