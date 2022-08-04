class InterventionCreator
  def initialize(observation)
    @observation = observation
  end

  def process
    @observation.observation_type = :intervention
    if @observation.valid?
      academic_year = @observation.school.academic_year_for(@observation.at)
      if academic_year&.current? && @observation.involved_pupils?
        @observation.points = @observation.intervention_type.score
      end
      @observation.save
    end
    @observation.persisted?
  end
end
