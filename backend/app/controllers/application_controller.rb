class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { error: error.message }, status: :bad_request
  end

  private

  def render_validation_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
