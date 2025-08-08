# frozen_string_literal: true

class Scoreboards::SchoolSummaryComponent < ApplicationComponent
  attr_reader :podium, :user, :audience

  include ApplicationHelper

  def initialize(podium:, title: nil, audience: :adult, user: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @podium = podium
    @title = title
    @user = user
    @audience = audience
  end

  def title
    @title || I18n.t('components.scoreboard_summary.title')
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
    4
  end

  def observations
    scope = other_schools? ? scoreboard.observations : Observation
    scope.for_visible_schools.not_including(school).recorded_since(school.current_academic_year.start_date..).by_date.with_points.sample(limit)
  end

  def timeline_title
    if other_schools?
      if Flipper.enabled?(:new_dashboards_2024, user)
        I18n.t('components.scoreboard_summary.recent_scoreboard_activity')
      else
        I18n.t('components.scoreboard_summary.recent_scoreboard_activity_html', scoreboard_path: scoreboard_path(scoreboard)).html_safe
      end
    else
      I18n.t('components.scoreboard_summary.recent_activity')
    end
  end

  def render?
    podium&.scoreboard && helpers.can?(:read, podium.scoreboard)
  end
end
