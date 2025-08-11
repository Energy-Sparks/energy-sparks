module Scoreboards
  class ActivityComponentPreview < ViewComponent::Preview
    def example(slug: nil, show_positions: true, limit: 5)
      school = slug ? School.find(slug) : School.active.sample
      podium = Podium.create(school: school, scoreboard: school.scoreboard)
      observations = school.scoreboard.observations.for_visible_schools.not_including(school).by_date.with_points.sample(limit)
      render(Scoreboards::ActivityComponent.new(observations:, podium:, show_positions:))
    end
  end
end
