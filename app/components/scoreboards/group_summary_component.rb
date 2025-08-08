module Scoreboards
  class GroupSummaryComponent < ApplicationComponent
    attr_reader :school_group, :user, :podium

    def initialize(school_group:, podium:, user:, **kwargs)
      super
      @school_group = school_group
      @podium = podium
      @user = user
    end

    def render?
      podium&.scoreboard
    end

    # FIXME
    #    def podium
    #      @podium ||= Podium.create(school: school_group.schools.sample, scoreboard: school_group.schools.sample.scoreboard)
    #    end
  end
end
