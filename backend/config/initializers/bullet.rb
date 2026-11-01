if defined?(Bullet)
  Bullet.enable = Rails.env.development? || Rails.env.test?
  Bullet.raise = Rails.env.test?
  Bullet.add_footer = Rails.env.development?
end
