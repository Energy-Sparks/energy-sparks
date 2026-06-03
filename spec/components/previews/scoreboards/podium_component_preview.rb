module Scoreboards
  class PodiumComponentPreview < ViewComponent::Preview
    def example(slug: nil)
      school = slug ? School.find(slug) : School.active.sample
      podium = Podium.create(school: school, scoreboard: school.scoreboard)
      render(Scoreboards::PodiumComponent.new(podium: podium, user: User.admin.first))
    end
  end
end
