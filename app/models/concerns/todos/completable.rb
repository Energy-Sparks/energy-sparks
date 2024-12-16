module Todos
  module Completable
    extend ActiveSupport::Concern

    # For models which can have todos completed against them, such as audit and programme

    included do
      has_many :completed_todos, as: :completable, dependent: :destroy
      has_many :completed_tasks, through: :completed_todos, source: :todo, class_name: 'Todo'
      has_many :completed_activity_types, through: :completed_todos, source: :activity_type
      has_many :completed_intervention_types, through: :completed_todos, source: :intervention_type

      # used to restrict returned audits or programmes, only return those that should have
      # tasks checked off against
      scope :completable, -> { raise NoMethodError, 'Implement completable scope in subclass!' }
    end

    def assignable_todos
      assignable.todos
    end

    def assignable_todo_ids
      assignable_todos.ids
    end

    def completed_todo_ids
      completed_todos.pluck(:todo_id)
    end

    def has_todos?
      assignable_todo_ids.any?
    end

    def nothing_todo?
      assignable_todo_ids.none?
    end

    def completable?
      has_todos? && todos_complete?
    end

    def todos_complete?
      (assignable_todo_ids - completed_todo_ids).empty?
    end

    def task_complete!(task:, recording:)
      todos = Todo.where(task: task, assignable: assignable)
      return if todos.none?

      # mark all matching todos done for programe or audit (really should be only one per programme or audit)
      todos.each do |todo|
        todo.complete!(completable: self, recording: recording)
      end
    end

    def complete_todos_this_academic_year!
      assignable.todos.each do |todo|
        recording = todo.latest_recording_for(completable: self)
        if recording.present?
          todo.complete!(completable: self, recording: recording)
        end
      end
      self.complete! if completable?
    end

    def assignable
      # return programme type or audit
      raise NoMethodError, 'Implement assignable'
    end

    def completed?
      raise NoMethodError, 'Implement completed?!'
    end

    def complete!
      raise NoMethodError, 'Implement complete!'
    end
  end
end
