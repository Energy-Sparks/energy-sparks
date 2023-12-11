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
    if other_schools?
      scoreboard.observations.not_including(school).by_date.limit(limit)
    else
      Observation.not_including(school).by_date.limit(limit)
    end
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
