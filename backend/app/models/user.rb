class User < ApplicationRecord
  has_secure_password

  ROLES = %w[hr_manager].freeze

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }
  before_validation { self.email = email.to_s.strip.downcase }

  def hr_manager?
    role == "hr_manager"
  end
end
