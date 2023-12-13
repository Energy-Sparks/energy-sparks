class ScoreboardSummaryComponentPreview < ViewComponent::Preview
  def with_points
    school = School.find_by(slug: 'ashbrook-school')
    podium = Podium.create(school: school, scoreboard: school.scoreboard)

    render(ScoreboardSummaryComponent.new(podium: podium))
  end

  def without_points
    school = School.find_by(slug: 'st-mary-and-st-giles-church-of-england-school-south-site')
    podium = Podium.create(school: school, scoreboard: school.scoreboard)

    render(ScoreboardSummaryComponent.new(podium: podium))
  end
end
