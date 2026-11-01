require_relative "boot"
require "rails"
require "action_controller/railtie"
require "active_record/railtie"
require "active_model/railtie"
require "active_job/railtie"
require "logger"
require "uri"
require "sidekiq/web"

Bundler.require(*Rails.groups)

module AcmePayroll
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
    config.active_job.queue_adapter = :sidekiq
    config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"), namespace: "acme-payroll", connect_timeout: 1, read_timeout: 1, write_timeout: 1 }
    config.filter_parameters += %i[password password_confirmation authorization]
  end
end
