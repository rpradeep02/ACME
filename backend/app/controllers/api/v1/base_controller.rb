module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      private

      attr_reader :current_user

      def authenticate_user!
        header = request.headers["Authorization"].to_s
        token = header.delete_prefix("Bearer ").presence
        raise JWT::DecodeError if token.nil? || token == header

        payload, = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256", iss: "acme-payroll", verify_iss: true)
        @current_user = User.find(payload.fetch("sub"))
        render json: { error: "Forbidden" }, status: :forbidden unless @current_user.hr_manager?
      rescue JWT::DecodeError, JWT::ExpiredSignature, KeyError, ActiveRecord::RecordNotFound
        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def issue_token(user)
        JWT.encode({ sub: user.id, role: user.role, iss: "acme-payroll", iat: Time.now.to_i,
                     exp: 8.hours.from_now.to_i }, Rails.application.secret_key_base, "HS256")
      end

      def serialize_salary(record)
        return nil unless record

        { id: record.id, annual_salary: record.annual_salary.to_f, currency: record.currency,
          effective_from: record.effective_from, effective_to: record.effective_to }
      end

      def serialize_employee(employee, include_history: false)
        payload = {
          id: employee.id, employee_code: employee.employee_code, first_name: employee.first_name,
          last_name: employee.last_name, full_name: "#{employee.first_name} #{employee.last_name}",
          email: employee.email, country_code: employee.country_code, department: employee.department,
          job_title: employee.job_title, status: employee.status, hire_date: employee.hire_date,
          current_salary: serialize_salary(employee.current_salary)
        }
        payload[:salary_history] = employee.salary_records.map { |record| serialize_salary(record) } if include_history
        payload
      end

      def refresh_dashboard_async
        DashboardSnapshot.expire!
        DashboardCacheRefreshJob.perform_later
      end

      def audit!(action, record, metadata = {})
        AuditEvent.create!(user: current_user, action: action, auditable: record, metadata: metadata)
      end
    end
  end
end
