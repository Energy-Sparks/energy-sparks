class Scoreboards::ScoreboardSummaryComponentPreview < ViewComponent::Preview
  # create a class so we can use the scorable concern
  class AllScorableSchools
    include Scorable

    def initialize
    end

    def schools
      School
    end

    def self.sanitize_sql_array(*params)
      School.sanitize_sql_array(*params)
    end
  end

  def school_with_points
    school = AllScorableSchools.new.scored_schools(recent_boundary: 6.months.ago, academic_year: false).to_a.first
    podium = Podium.create(school: school, scoreboard: school.scoreboard)

    render(Scoreboards::ScoreboardSummaryComponent.new(podium: podium))
  end

  def school_without_points
    school = AllScorableSchools.new.scored_schools(recent_boundary: 6.months.ago, academic_year: false).to_a.last
    podium = Podium.create(school: school, scoreboard: school.scoreboard)

    render(Scoreboards::ScoreboardSummaryComponent.new(podium: podium))
  end
end
