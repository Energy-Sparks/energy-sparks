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

      def todos_complete?
        (all_todo_ids - completed_todo_ids).empty?
      end

      def complete!
        raise NoMethodError, 'Implement complete! in subclass!'
      end
    end
  end
end
