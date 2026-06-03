module Scoreboards
  class ActivityTableComponent < ApplicationComponent
    attr_reader :observations, :observation_style

    def initialize(observations:,
                   podium: nil,
                   show_positions: false,
                   show_school: false,
                   show_date: false,
                   show_actions: false,
                   observation_style: :description,
                   **_kwargs)
      super
      @observations = observations
      @podium = podium
      @show_positions = show_positions
      @show_school = show_school
      @show_date = show_date
      @show_actions = show_actions
      @observation_style = observation_style
      raise 'Must supply podium if showing positions' if @podium.nil? && @show_positions == true
    end

    def show_actions?
      @show_actions
    end

    def show_positions?
      @show_positions
    end

    def show_school?
      @show_school
    end

    def show_date?
      @show_date
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
