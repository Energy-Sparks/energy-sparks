class ScoreboardActivityComponent < ApplicationComponent
  attr_reader :observations

  def initialize(observations:, podium: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @observations = observations
    @podium = podium
  end

  def position(school)
    @podium.position_for(school)
  end
end
