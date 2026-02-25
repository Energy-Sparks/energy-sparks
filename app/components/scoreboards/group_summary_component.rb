module Scoreboards
  class GroupSummaryComponent < ApplicationComponent
    attr_reader :school_group, :user

    def initialize(school_group:, user:, limit: 20, **kwargs)
      super
      @school_group = school_group
      @user = user
      @limit = limit
    end

    def podium
      @podium ||= Podium.create(school: featured_school, scoreboard: @school_group)
    end

    def observations
      @school_group.observations.by_date.limit(@limit)
    end

    private

    def featured_school
      scored_schools = @school_group.scored_schools
      scored_schools.first
    end
  end
end
