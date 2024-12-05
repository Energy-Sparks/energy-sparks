module Todos
  module Completable
    extend ActiveSupport::Concern

    # For models which can have todos completed against them, such as audit and programme

    included do
      has_many :completed_todos, as: :completable, dependent: :destroy, class_name: 'CompletedTodo'
      has_many :completed_tasks, through: :completed_todos, source: :todo, class_name: 'Todo'
      has_many :completed_activity_types, through: :completed_todos, source: :activity_type
      has_many :completed_intervention_types, through: :completed_todos, source: :intervention_type

      # used to restrict returned audits or programmes, only return those that should have
      # tasks checked off against
      scope :completable, -> { raise NoMethodError, 'Implement completable scope in subclass!' }

      def assignable
        # return programme type or audit
        raise NoMethodError, 'Implement assignable in subclass!'
      end

      def todos
        assignable.todos
      end

      def school
        self.school
      end

      # def tasks(task_type = nil)
      #   scope = task_type.nil? ? todos : todos.where(task_type: task_type.to_s)
      #   scope.map(&:task).uniq
      # end

      def all_todo_ids
        todos.ids
      end

      def completed_todo_ids
        completed_todos.pluck(:todo_id)
      end

      def nothing_todo?
        all_todo_ids.none?
      end

      def todos_complete?
        ## new feature! Don't say all the todos are complete if there aren't any? Check this is required behaviour
        return false if nothing_todo?

        (all_todo_ids - completed_todo_ids).empty?
      end

      def recognise_existing_progress!
        assignable.todos.each do |todo|
          recording = todo.latest_recording_for_completable(self)
          if recording.present?
            todo.complete!(self, recording)
          end
        end
        self.complete! if todos_complete?
      end

      def complete!
        raise NoMethodError, 'Implement complete! in subclass!'
      end
    end
  end
end
