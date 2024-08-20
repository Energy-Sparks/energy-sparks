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
    @podium.position_for(school)
  end
end
