require "active_support/core_ext/integer/time"
Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::Logger.new($stdout)
  config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")
  config.force_ssl = true
  config.active_record.dump_schema_after_migration = false
end
