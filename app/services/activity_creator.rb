class ActivityCreator
  def initialize(activity)
    @activity = activity
  end

  def process
    if @activity.activity_type
      @activity.points = @activity.activity_type.score
      @activity.activity_category = @activity.activity_type.activity_category
    end

    if @activity.save
      process_programmes if started_active_programmes.any?
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
