module Api
  module V1
    class SalaryRecordsController < BaseController
      def create
        employee = Employee.find(params[:employee_id])
        result = SalaryRecords::Create.new(employee: employee, attributes: salary_params, actor: current_user).call
        if result.success?
          invalidate_dashboard_cache!
          render json: serialize_salary(result.record), status: :created
        else
          render json: { errors: result.errors || ["Unable to create salary record"] }, status: :unprocessable_entity
        end
      end

      private

      def salary_params
        params.require(:salary).permit(:annual_salary, :currency, :effective_from, :effective_to)
      end
    end
  end
end
