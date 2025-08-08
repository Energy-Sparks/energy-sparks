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

  def timeline_title
    if other_schools?
      I18n.t('components.scoreboard_summary.recent_scoreboard_activity')
    else
      I18n.t('components.scoreboard_summary.recent_activity')
    end
  end

  def render?
    podium&.scoreboard
  end

  private

  def other_schools?
    podium.positions.count > 1
  end
end
