module Api
  module V1
    class DashboardController < BaseController
      def show
        expires_in DashboardSnapshot::CACHE_TTL, public: false, stale_while_revalidate: 30.seconds
        render json: DashboardSnapshot.fetch
      end
    end
  end
end
