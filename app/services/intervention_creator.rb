class InterventionCreator
  def initialize(observation)
    @observation = observation
  end

  def process
    @observation.observation_type = :intervention
    if @observation.valid?
      academic_year = @observation.school.calendar_area.academic_year_for(@observation.at)
      if academic_year && academic_year.current?
        @observation.points = @observation.intervention_type.points
      end
      @observation.save
    end
    @observation.persisted?
  end
end
