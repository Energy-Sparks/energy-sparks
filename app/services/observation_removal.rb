class ObservationRemoval
  def initialize(observation)
    @observation = observation
  end

  def process
    academic_year = @observation.school.academic_year_for(@observation.at)
    if academic_year && academic_year.current?
      @observation.destroy
    else
      @observation.update_attribute(:visible, false)
      if Flipper.enabled?(:todos)
        CompletedTodo.where(recording: @observation).destroy_all if @observation.intervention?
      end
    end
  end
end
