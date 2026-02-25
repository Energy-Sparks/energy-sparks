class TimelineComponentPreview < ViewComponent::Preview
  # @param show_header toggle
  # @param padding toggle
  # @param show_actions toggle
  # @param show_date toggle
  # @param show_school toggle
  # @param observation_style select { choices: [compact, description, full] }
  def default(show_header: true, padding: true, show_actions: true, show_date: true, show_school: true, observation_style: :full)
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

    render(TimelineComponent.new(observations: observations, show_header:, padding:, table_opts: { show_actions:, show_date:, show_school:, observation_style: }))
  end
end
