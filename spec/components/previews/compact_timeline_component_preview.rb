class CompactTimelineComponentPreview < ViewComponent::Preview
  def with_observations
    audit = Audit.last

    observations = [
      Observation.find_by(observation_type: 'activity'),
      Observation.new(school: audit.school, observation_type: 'audit', audit: audit, at: Time.zone.yesterday),
      Observation.new(school: audit.school, observation_type: 'audit_activities_completed', audit: audit, at: Time.zone.yesterday, points: SiteSettings.current.audit_activities_bonus_points),
      Observation.find_by(observation_type: 'intervention'),
      Observation.find_by(observable_type: 'TransportSurvey'),
      Observation.find_by(observable_type: 'Programme'),
      Observation.find_by(observation_type: 'school_target'),
      Observation.find_by(observation_type: 'temperature')
    ].compact.sort_by(&:at).reverse

    render(CompactTimelineComponent.new(observations: observations))
  end
end
