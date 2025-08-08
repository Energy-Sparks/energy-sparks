module Scoreboards
  class ScoreboardActivityComponent < ApplicationComponent
    attr_reader :observations

    def initialize(observations:, podium: nil, show_positions: true, id: nil, classes: '')
      super(id: id, classes: classes)
      @observations = observations
      @podium = podium
      @show_positions = show_positions
    end

    def show_positions?
      @show_positions
    end

    def render?
      observations&.any?
    end

    def position(school)
      position = scored_schools.position(school)
      "#{position}#{position.ordinal}" unless position.nil?
    end

    private

    def scored_schools
      @scored_schools ||= @podium.scoreboard.scored_schools.with_points(always_include: @podium.school)
    end
  end
end
