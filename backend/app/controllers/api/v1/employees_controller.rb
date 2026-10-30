module Api
  module V1
    class EmployeesController < BaseController
      SORT_COLUMNS = %w[employee_code first_name last_name country_code department hire_date].freeze

      def index
        scope = Employee.all
        scope = scope.where(status: params[:status]) if Employee::STATUSES.include?(params[:status])
        scope = scope.where(country_code: params[:country_code].upcase) if params[:country_code].present?
        scope = scope.where(department: params[:department]) if params[:department].present?
        if params[:currency].present?
          scope = scope.joins(:salary_records).merge(SalaryRecord.current_on).where(salary_records: { currency: params[:currency].upcase }).distinct
        end
        if params[:q].present?
          query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].strip)}%"
          scope = scope.where("employee_code LIKE :q OR first_name LIKE :q OR last_name LIKE :q OR email LIKE :q", q: query)
        end

        total = scope.count
        page = [params.fetch(:page, 1).to_i, 1].max
        per_page = [[params.fetch(:per_page, 25).to_i, 1].max, 100].min
        sort = SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "employee_code"
        direction = params[:direction] == "desc" ? :desc : :asc
        records = scope.order(sort => direction).offset((page - 1) * per_page).limit(per_page).includes(:salary_records)

        render json: { data: records.map { |employee| serialize_employee(employee) },
                       pagination: { page: page, per_page: per_page, total: total,
                                     total_pages: (total.to_f / per_page).ceil } }
      end

      def show
        employee = Employee.includes(:salary_records).find(params[:id])
        render json: serialize_employee(employee, include_history: true)
      end

      def create
        employee = Employee.new(employee_params)
        opening_salary = salary_params

        Employee.transaction do
          employee.save!
          record = employee.salary_records.create!(opening_salary)
          audit!("employee_created", employee, employee_code: employee.employee_code)
          audit!("salary_created", record, employee_code: employee.employee_code, currency: record.currency)
        end
        render json: serialize_employee(employee.reload, include_history: true), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def update
        employee = Employee.find(params[:id])
        Employee.transaction do
          employee.update!(employee_update_params)
          audit!("employee_updated", employee, changed_fields: employee.previous_changes.keys - %w[updated_at])
        end
        render json: serialize_employee(employee.reload)
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      private

      def employee_params
        params.require(:employee).permit(:employee_code, :first_name, :last_name, :email,
                                         :country_code, :department, :job_title, :status, :hire_date)
      end

      def employee_update_params
        params.require(:employee).permit(:first_name, :last_name, :email, :country_code,
                                         :department, :job_title, :status, :hire_date)
      end

      def salary_params
        params.require(:salary).permit(:annual_salary, :currency, :effective_from, :effective_to)
      end
    end
  end
end
