class TemperatureObservationCreator
  def initialize(observation)
    @observation = observation
  end

  def process
    @observation.observation_type = :temperature
    if @observation.valid?
      academic_year = @observation.school.academic_year_for(@observation.at)
      same_day_observations = @observation.school.observations.temperature.where('DATE(at) = DATE(?)', @observation.at)
      @observation.points = 5 if same_day_observations.empty? && academic_year && academic_year.current?
      @observation.save
    end
    @observation.persisted?
  end
end
