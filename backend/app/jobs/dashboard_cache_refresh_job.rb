class DashboardCacheRefreshJob < ApplicationJob
  queue_as :low
  retry_on Redis::BaseError, wait: :polynomially_longer, attempts: 5

  def perform
    DashboardSnapshot.refresh!
  end
end
