require "active_support/core_ext/integer/time"
Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_classes = true
  config.active_support.deprecation = :stderr
  config.active_job.queue_adapter = :test
  config.secret_key_base = "test-secret-key-base-for-acme-payroll-test-only"
  config.action_dispatch.show_exceptions = :none
end
