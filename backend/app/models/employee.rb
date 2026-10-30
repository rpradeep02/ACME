class Employee < ApplicationRecord
  STATUSES = %w[active on_leave terminated].freeze

  has_many :salary_records, -> { order(effective_from: :desc) }, dependent: :restrict_with_error

  validates :employee_code, presence: true, uniqueness: true, format: { with: /\AEMP\d{5}\z/ }
  validates :first_name, :last_name, :email, :country_code, :department, :job_title, :hire_date, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :country_code, format: { with: /\A[A-Z]{2}\z/, message: "must be a two-letter ISO country code" }
  validates :status, inclusion: { in: STATUSES }
  before_validation do
    self.email = email.to_s.strip.downcase
    self.country_code = country_code.to_s.upcase
  end

  def current_salary(on: Date.current)
    salary_records.detect { |record| record.effective_from <= on && (record.effective_to.nil? || record.effective_to >= on) }
  end
end
