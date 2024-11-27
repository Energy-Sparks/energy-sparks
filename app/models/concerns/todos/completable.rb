module Todos
  module Completable
    extend ActiveSupport::Concern

    included do
      has_many :completed_todos, as: :completable, dependent: :destroy, class_name: 'CompletedTodo'
      has_many :completed_tasks, through: :completed_todos, source: :todo, class_name: 'Todo'
      has_many :completed_activity_types, through: :completed_todos, source: :activity_type
      has_many :completed_intervention_types, through: :completed_todos, source: :intervention_type
    end
  end
end
