class Rack::Attack
  # Uses the configured Rails cache; Redis can be enabled for multi-instance deployments.
  Rack::Attack.cache.store = Rails.cache

  # Protect credential endpoints from brute-force attempts. Keyed by IP so
  # one user cannot lock out an entire organization.
  throttle("sessions/ip", limit: 10, period: 5.minutes) do |request|
    request.ip if request.post? && request.path == "/api/v1/session"
  end

  self.throttled_responder = lambda do |request|
    retry_after = (request.env["rack.attack.match_data"] || {})[:period]
    [429, { "Content-Type" => "application/json", "Retry-After" => retry_after.to_s },
     [{ error: "Rate limit exceeded. Try again later." }.to_json]]
  end
end

Rails.application.config.middleware.use Rack::Attack
