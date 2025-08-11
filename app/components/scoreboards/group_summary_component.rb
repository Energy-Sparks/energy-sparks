module Scoreboards
  class GroupSummaryComponent < ApplicationComponent
    attr_reader :school_group, :user

    def initialize(school_group:, user:, **kwargs)
      super
      @school_group = school_group
      @user = user
    end

    def render?
      podium&.scoreboard
    end

    def podium
      @podium ||= Podium.create(school: featured_school, scoreboard: @school_group)
    end

    def observations
      @school_group.observations.by_date.limit(20)
    end

    private

    def featured_school
      scored_schools = @school_group.scored_schools # all scored schools in group
      scored_schools.first # most points
    end
  end
end
