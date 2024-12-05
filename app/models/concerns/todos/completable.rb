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

      def has_todos?
        all_todo_ids.any?
      end

      def nothing_todo?
        all_todo_ids.none?
      end

      def completable?
        has_todos? && todos_complete?
      end

      def todos_complete?
        ## new feature! Don't say all the todos are complete if there aren't any? Check this is required behaviour
        return false if nothing_todo?

        (all_todo_ids - completed_todo_ids).empty?
      end

      def task_complete!(task)
        todos = Todo.where(task: task, assignable: assignable)
        return unless todos.any?

        # mark all matching todos done for programe or audit (really should be only one per programme or audit)
        todos.each do |todo|
          todo.complete!(completable: completable, recording: @recording)
        end
      end

      def latest_recording(todo)
        todo.latest_recording(completable: self)
      end

      def complete_todos_this_academic_year!
        assignable.todos.each do |todo|
          recording = latest_recording(todo)
          if recording.present?
            todo.complete!(self, recording)
          end
        end
        self.complete! if completable?
      end

      def complete!
        raise NoMethodError, 'Implement complete! in subclass!'
      end
    end
  end
end
