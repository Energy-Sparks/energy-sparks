class TimelineComponentPreview < ViewComponent::Preview
  def with_observations
    programme = Programme.all.last
    audit = Audit.all.last

    observations = [
      Observation.find_by(observation_type: 'activity'),
      Observation.new(school: audit.school, observation_type: 'audit', audit: audit, at: Time.zone.yesterday),
      Observation.new(school: audit.school, observation_type: 'audit_activities_completed', audit: audit, at: Time.zone.yesterday),
      Observation.find_by(observation_type: 'intervention'),
      Observation.find_by(observation_type: 'observable'),
      Observation.new(school: programme.school, observation_type: 'programme', programme: programme, at: Time.zone.yesterday),
      Observation.find_by(observation_type: 'school_target'),
      Observation.find_by(observation_type: 'temperature'),
    ].compact
    render(TimelineComponent.new(observations: observations, show_actions: true))
  end
end
