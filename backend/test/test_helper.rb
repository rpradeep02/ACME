ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: 1)
  fixtures :all

  def hr_user
    @hr_user ||= User.create!(email: "hr-test@acme.example", password: "Password123!", role: "hr_manager")
  end

  def auth_headers(user = hr_user)
    token = JWT.encode({ sub: user.id, iss: "acme-payroll", exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, "HS256")
    { "Authorization" => "Bearer #{token}" }
  end

  def create_employee(attributes = {})
    Employee.create!({ employee_code: "EMP12345", first_name: "Taylor", last_name: "Morgan",
      email: "taylor.morgan@example.com", country_code: "IN", department: "Engineering",
      job_title: "Senior Engineer", status: "active", hire_date: Date.new(2022, 1, 10) }.merge(attributes))
  end
end
