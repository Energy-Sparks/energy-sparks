module Scoreboards
  class SummaryComponent < ApplicationComponent
    include ApplicationHelper

    attr_reader :podium, :user

    renders_one :title
    renders_one :description
    renders_one :recent_activity_title
    renders_one :recent_activity_description
    renders_one :recent_activity_link

    def initialize(podium:, user:, show_recent_activity: true, **kwargs)
      super
      @podium = podium
      @featured_school = featured_school
      @user = user
      @show_recent_activity = show_recent_activity
    end

    # TODO do we need helper?
    def render?
      podium&.scoreboard && helpers.can?(:read, podium.scoreboard)
    end

    def show_recent_activity?
      @show_recent_activity
    end

    def other_schools?
      podium.positions.count > 1
    end

    def featured_school
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
      scope.for_visible_schools.not_including(featured_school).recorded_since(featured_school.current_academic_year.start_date..).by_date.with_points.sample(limit)
    end
  end
end
