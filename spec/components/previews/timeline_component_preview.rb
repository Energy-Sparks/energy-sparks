class TimelineComponentPreview < ViewComponent::Preview
  def with_observations
    observations = School.find_by(slug: 'freshford-church-school').observations.order(created_at: :desc).limit(4)
    render(TimelineComponent.new(observations: observations, show_actions: false))
  end
end
