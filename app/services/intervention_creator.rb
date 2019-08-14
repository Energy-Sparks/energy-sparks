class InterventionCreator
  def initialize(observation)
    @observation = observation
  end

  def process
    @observation.observation_type = :intervention
    if @observation.valid?
      @observation.points = @observation.intervention_type.points
      @observation.save
    end
    @observation.persisted?
  end
end
