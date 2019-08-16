class TemperatureObservationCreator
  def initialize(observation)
    @observation = observation
  end

  def process
    @observation.observation_type = :temperature
    if @observation.valid?
      @observation.points = 5 if @observation.school.observations.temperature.where('DATE(at) = DATE(?)', @observation.at).empty?
      @observation.save
    end
    @observation.persisted?
  end
end
