class TaskRecording
  SUPPORTED_MODELS = [Activity, Observation].freeze

  def self.new(recording, user)
    unless SUPPORTED_MODELS.include?(recording.class)
      raise ArgumentError, "Unsupported recordable type: #{recording.class.name}"
    end

    subclass = const_get(recording.class.name)
    subclass.new(recording, user)
  end

  def initialize(recording, user)
    @recording = recording
    @user = user
    @school = recording.school
  end

  def process
    if @recording.save
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

  class Observation < TaskRecording
    def observation
      @recording
    end

    def task
      @task ||= observation.intervention_type
    end
  end

  class Activity < TaskRecording
    def activity
      @recording
    end

    def task
      @task ||= activity.activity_type
    end

    def initialize
      super
      activity.activity_category = activity.activity_type.activity_category if activity.activity_type
    end
  end
end
