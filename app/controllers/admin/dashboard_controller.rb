module Admin
  class DashboardController < BaseController
    def index
      @metrics = MetricsSummary.new
    end
  end
end
