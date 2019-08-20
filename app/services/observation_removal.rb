class ObservationRemoval
  def initialize(observation)
    @observation = observation
  end

  def process
    academic_year = @observation.school.calendar_area.academic_year_for(@observation.at)
    if academic_year && academic_year.current?
      @observation.destroy
    else
      @observation.update_attribute(:visible, false)
    end
  end
end
