# frozen_string_literal: true

module Scoreboards
  class PodiumComponent < ApplicationComponent
    attr_reader :podium, :i18n_scope

    def initialize(podium: nil, user: nil, path_to_scoreboard: nil, i18n_scope: 'components.podium', **_kwargs)
      super
      @podium = podium
      @user = user
      @i18n_scope = i18n_scope
      @path_to_scoreboard = path_to_scoreboard
    end

    def path_to_scoreboard
      @path_to_scoreboard || scoreboard_path(podium.scoreboard)
    end

    def path_to_school(school)
      controller_path == 'pupils/schools' ? pupils_school_path(school) : school_path(school)
    end

    def school
      podium.school
    end

    def national_podium
      podium.national_podium
    end

    def render?
      podium
    end
  end
end
