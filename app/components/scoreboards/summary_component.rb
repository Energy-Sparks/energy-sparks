module Scoreboards
  class SummaryComponent < ApplicationComponent
    include ApplicationHelper

    attr_reader :podium, :user

    renders_one :title
    renders_one :description
    renders_one :timeline_title
    renders_one :timeline_description
    renders_one :timeline_link

    def initialize(podium:, user:, **kwargs)
      super
      @podium = podium
      @featured_school = featured_school
      @user = user
    end

    # TODO do we need helper?
    def render?
      podium&.scoreboard && helpers.can?(:read, podium.scoreboard)
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

    # TODO: user alternative period?
    def observations
      scope = other_schools? ? scoreboard.observations : Observation
      scope.for_visible_schools.not_including(featured_school).recorded_since(featured_school.current_academic_year.start_date..).by_date.with_points.sample(limit)
    end
  end
end
