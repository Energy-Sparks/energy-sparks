class ScoreboardSummaryComponentPreview < ViewComponent::Preview
  def with_score
    school = School.find_by(slug: 'ashbrook-school')
    podium = Podium.create(school: school, scoreboard: school.scoreboard)

    render(ScoreboardSummaryComponent.new(podium: podium))
  end
end
