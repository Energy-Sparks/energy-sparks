class ActivityCreator
  def initialize(activity)
    @activity = activity
  end

  def process
    if @activity.activity_type
      @activity.activity_category = @activity.activity_type.activity_category
    end

    if @activity.save
      process_programmes if started_active_programmes.any?
      create_observation
    end
    @activity.persisted?
  end

  private

  def process_programmes
    started_active_programmes.each do |programme|
      programme_activities(programme).each { |programme_activity| update_with_activity!(programme_activity) }
      programme.completed! if programme.programme_activities.all?(&:activity)
    end
  end

  def create_observation
    academic_year = @activity.school.academic_year_for(@activity.happened_on)
    points = if academic_year && academic_year.current?
               @activity.activity_type.score
             end
    Observation.create!(
      school: @activity.school,
      observation_type: :activity,
      activity: @activity,
      at: @activity.happened_on,
      points: points
    )
  end

  def started_active_programmes
    @activity.school.programmes.started.active
  end

  def programme_activities(programme)
    programme.programme_activities.where(activity_type: @activity.activity_type)
  end

  def update_with_activity!(programme_activity)
    programme_activity.update!(activity: @activity)
  end
end
