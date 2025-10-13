module DashboardTimeline
  extend ActiveSupport::Concern

  def setup_timeline(school_observations)
    school_observations.visible.order('at DESC, created_at DESC').limit(10)
  end

  def setup_target_timeline(school_target)
    school = school_target.school
    school.observations.where('at >= :start_date AND at <= :target_date AND visible = TRUE', start_date: school_target.start_date, target_date: school_target.target_date).where.not(observation_type: :school_target).order('at DESC')
  end
end
