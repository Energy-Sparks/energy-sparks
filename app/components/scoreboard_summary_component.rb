# frozen_string_literal: true

class ScoreboardSummaryComponent < ViewComponent::Base
  attr_reader :podium

  include ApplicationHelper

  def initialize(podium:)
    @podium = podium
  end

  def other_schools?
    podium.positions.count > 1
  end

  def school
    podium.school
  end

  def scoreboard
    podium.scoreboard
  end

  def limit
    5
  end

  def observations
    scope = other_schools? ? scoreboard.observations : Observation
    scope.for_visible_schools.not_including(school).recorded_since(school.current_academic_year.start_date).by_date.limit(limit)
  end

  def timeline_title
    if other_schools?
      I18n.t("components.scoreboard_summary.recent_scoreboard_activity")
    else
      I18n.t("components.scoreboard_summary.recent_activity")
    end
  end

  def render?
    podium&.includes_school? && helpers.can?(:read, podium.scoreboard)
  end
end
