class TimelineComponentPreview < ViewComponent::Preview
  def with_observations
    # observations = School.find_by(slug: 'freshford-church-school').observations.order(created_at: :desc).limit(4)
    observations = [
      Observation.find_by(observation_type: 'activity'),
      Observation.find_by(observation_type: 'audit'),
      Observation.find_by(observation_type: 'audit_activities_completed'),
      Observation.find_by(observation_type: 'intervention'),
      Observation.find_by(observation_type: 'observable'),
      Observation.find_by(observation_type: 'programme'),
      Observation.find_by(observation_type: 'school_target'),
      Observation.find_by(observation_type: 'temperature'),
    ].compact
    render(TimelineComponent.new(observations: observations, show_actions: false))
  end
end
