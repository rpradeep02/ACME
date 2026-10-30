module Api
  module V1
    class DashboardController < BaseController
      def show
        active = SalaryRecord.current_on.joins(:employee).where.not(employees: { status: "terminated" })
        payroll = active.group(:currency).sum(:annual_salary).map do |currency, amount|
          { currency: currency, annual_total: amount.to_f, employee_count: active.where(currency: currency).count }
        end.sort_by { |row| row[:currency] }

        render json: {
          employee_count: Employee.count,
          active_employee_count: Employee.where(status: "active").count,
          countries_count: Employee.distinct.count(:country_code),
          headcount_by_country: Employee.group(:country_code).order(:country_code).count.map { |code, count| { country_code: code, count: count } },
          payroll_by_currency: payroll,
          departments: Employee.where(status: "active").group(:department).order(:department).count.map { |name, count| { department: name, count: count } }
        }
      end
    end
  end
end
