module DashboardTimeline
  extend ActiveSupport::Concern

  def setup_timeline(school_observations)
    school_observations.visible.order('at DESC').limit(10)
  end
end
