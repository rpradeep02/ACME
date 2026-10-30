class SalaryRecord < ApplicationRecord
  CURRENCY_CODES = %w[USD INR GBP EUR CAD SGD AUD AED].freeze

  belongs_to :employee

  validates :annual_salary, numericality: { greater_than: 0, less_than: 1_000_000_000 }
  validates :currency, inclusion: { in: CURRENCY_CODES }
  validates :effective_from, presence: true
  validate :effective_to_not_before_start
  validates :effective_from, uniqueness: { scope: :employee_id, message: "already has a salary record for this employee" }

  scope :current_on, ->(date = Date.current) {
    where("effective_from <= ? AND (effective_to IS NULL OR effective_to >= ?)", date, date)
  }

  private

  def effective_to_not_before_start
    return if effective_to.blank? || effective_from.blank? || effective_to >= effective_from

    errors.add(:effective_to, "must be on or after the effective start date")
  end
end
