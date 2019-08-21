module DashboardTimeline
  extend ActiveSupport::Concern

  def setup_timeline
    @observations = @school.observations.order('at DESC').limit(10)
  end
end
