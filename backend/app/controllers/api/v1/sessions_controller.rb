module Api
  module V1
    class SessionsController < ApplicationController
      def create
        user = User.find_by(email: params.require(:email).to_s.downcase.strip)
        if user&.authenticate(params.require(:password)) && user.hr_manager?
          token = JWT.encode({ sub: user.id, role: user.role, iss: "acme-payroll", iat: Time.now.to_i,
                               exp: 8.hours.from_now.to_i }, Rails.application.secret_key_base, "HS256")
          render json: { token: token, user: { id: user.id, email: user.email, role: user.role } }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def show
        authenticate_session!
        return if performed?

        render json: { id: @user.id, email: @user.email, role: @user.role }
      end

      private

      def authenticate_session!
        header = request.headers["Authorization"].to_s
        token = header.delete_prefix("Bearer ").presence
        raise JWT::DecodeError if token.nil? || token == header
        payload, = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256", iss: "acme-payroll", verify_iss: true)
        @user = User.find(payload.fetch("sub"))
        render json: { error: "Forbidden" }, status: :forbidden unless @user.hr_manager?
      rescue JWT::DecodeError, JWT::ExpiredSignature, KeyError, ActiveRecord::RecordNotFound
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end
