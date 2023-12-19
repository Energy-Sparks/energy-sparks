class TimelineComponentPreview < ViewComponent::Preview
  def with_observations
    audit = Audit.last

    observations = [
      Observation.find_by(observation_type: 'activity'),
      Observation.find_by(observation_type: 'intervention'),
      Observation.find_by(observation_type: 'temperature'),
      Observation.new(school: audit.school, observable: audit, observable_variation: 'ActivitiesCompleted', at: Time.zone.yesterday, points: SiteSettings.current.audit_activities_bonus_points),
      Observation.for_observable('Audit').last,
      Observation.for_observable('TransportSurvey').last,
      Observation.for_observable('Programme').last,
      Observation.for_observable('SchoolTarget').last,
    ].compact.sort_by(&:at).reverse

    render(TimelineComponent.new(observations: observations, show_actions: true))
  end
end
