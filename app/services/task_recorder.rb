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
        mark_todos_completed(completable)
        # mark programme or audit as complete if all tasks complete
        # add observation for both
        completable.complete! if completable.todos_complete?
      end
    end
    @recording.persisted?
  end

  private

  def mark_todos_completed(completable)
    # bail if programme_type or audit doesn't include task
    # return unless completable.assignable.tasks.include?(task)

    # find all todos for task for programme type or audit
    todos = Todo.where(task: task, assignable: completable.assignable)

    # mark all matching todos done for programe or audit (really should be only one per programme or audit)
    todos.each do |todo|
      todo.complete!(completable: completable, recording: @recording)
    end
  end

  def task
    raise NoMethodError, 'Implement in subclass!'
  end

  def completables
    @school.programmes.completable + @school.audits.completable
  end

  def assignables
    completables.map(:assignable)
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
      unless task
        raise ArgumentError, 'Activity recordings must have an associated activity type'
      end

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

      unless task
        raise ArgumentError, 'Observation recordings must have an associated intervention type'
      end

      observation.created_by = @user
      # observation.at ||= Time.zone.now # this is set in the controller
    end
  end
end
