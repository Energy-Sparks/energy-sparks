class TaskRecorder
  SUPPORTED_MODELS = %w(Activity Observation).freeze

  def self.new(recording, user)
    subclass_name = recording.class.to_s
    raise ArgumentError, "Unsupported recording type: #{recording.class.name}" unless SUPPORTED_MODELS.include?(subclass_name)

    subclass = const_get(subclass_name)
    subclass.allocate.tap { |object| object.send(:initialize, recording, user) }
  end

  def initialize(recording, user)
    @recording = recording
    @user = user
    @school = recording.school
    unless task
      raise ArgumentError, 'Recording must have an associated task'
    end
  end

  def process
    if @recording.save
      after_save

      # This is how activity creator logic works i.e. go through all subscribed programmes,
      # regardless of if activity_type or intervention_type is part of it or not.
      # It is probably less complicated than the alternative,
      # which would be find programme types or audits with task_id in,
      # then find the school's audits and programmes for these audit or programme_type

      completables.each do |completable|
        # mark todos as completed for given programme or audit
        completable.task_complete!(task: task, recording: @recording)

        # mark programme or audit as complete if tasks available and complete
        completable.complete! if completable.completable?
      end
    end

    @recording.persisted?
  end

  private

  def task
    raise NoMethodError, 'Implement in subclass!'
  end

  def completables
    @school.programmes.completable + @school.audits.completable
  end

  def after_save; end

  class Activity < TaskRecorder
    def activity
      @recording
    end

    def task
      @task ||= activity.activity_type
    end

    def initialize(recording, user)
      super(recording, user)

      activity.activity_category = activity.activity_type.activity_category
    end

    def after_save
      activity.observations.activity.create!(
        school: activity.school,
        at: activity.happened_on,
        created_by: @user
      )
    end
  end

  class Observation < TaskRecorder
    def observation
      @recording
    end

    def task
      @task ||= observation.intervention_type
    end

    def initialize(recording, user)
      super(recording, user)

      observation.created_by = @user
      # observation.at ||= Time.zone.now # this is set in the controller
    end
  end
end
