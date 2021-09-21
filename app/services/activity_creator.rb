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
      add_programme_activity(programme)
      programme.complete! if completed_programme?(programme)
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

  def add_programme_activity(programme)
    #create programme_activity for this programme, associated with programme, activity_type and activity
    #but not if there already is a record for this activity type, so just recording the first instance
    if programme_activities(programme).empty?
      programme.programme_activities.create!(activity_type: @activity.activity_type, activity: @activity)
    else
      # if programme activity already exists for this type, set the new activity
      programme_activities(programme).last.update(activity: @activity)
    end
  end

  def programme_activities(programme)
    programme.programme_activities.where(activity_type: @activity.activity_type)
  end

  def completed_programme?(programme)
    # Completed programme if all activity types for the programme type are in the list of completed  activities
    # (extra completed activities are ignored - activity types may have been removed from programme..)
    programme_type_activity_ids = programme.programme_type.activity_types.pluck(:id)
    programme_activity_types = programme.activities.map(&:activity_type).pluck(:id)
    (programme_type_activity_ids - programme_activity_types).empty?
  end
end
