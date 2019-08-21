module DashboardTimeline
  extend ActiveSupport::Concern

  def setup_timeline(school_observations)
    school_observations.order('at DESC').limit(10)
  end
end
