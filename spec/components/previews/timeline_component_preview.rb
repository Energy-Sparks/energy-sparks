class TimelineComponentPreview < ViewComponent::Preview
  def with_observations
    observations = School.find_by(slug: 'freshford-church-school').observations.limit(2)
    render(TimelineComponent.new(observations: observations, show_actions: false))
  end
end
