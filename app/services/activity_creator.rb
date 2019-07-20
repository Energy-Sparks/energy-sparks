class ActivityCreator
  def initialize(activity)
    @activity = activity
  end

  def process
    if @activity.activity_type
      @activity.points = @activity.activity_type.score
      @activity.activity_category = @activity.activity_type.activity_category
    end
    @activity.save
  end
end
