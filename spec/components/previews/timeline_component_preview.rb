class TimelineComponentPreview < ViewComponent::Preview
  def with_observations
    audit = Audit.last

    observations = [
      Observation.find_by(observation_type: :activity),
      Observation.find_by(observation_type: :intervention),
      Observation.find_by(observation_type: :temperature),
      Observation.new(school: audit.school, observable: audit, observation_type: :audit_activities_completed, at: Time.zone.yesterday, points: SiteSettings.current.audit_activities_bonus_points),
      Observation.find_by(observation_type: :audit),
      Observation.find_by(observation_type: :transport_survey),
      Observation.find_by(observation_type: :programme),
      Observation.find_by(observation_type: :school_target),
    ].compact.sort_by(&:at).reverse

    render(TimelineComponent.new(observations: observations, show_actions: true, user: User.admin.first))
  end
end
