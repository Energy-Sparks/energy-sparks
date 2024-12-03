module Todos
  module Assignable
    extend ActiveSupport::Concern

    # For models which can have todos assigned to them, such as audit and programme_type

    included do
      has_many :todos, as: :assignable, dependent: :destroy, class_name: 'Todo', inverse_of: :assignable

      has_many :activity_type_todos, -> { activity_types.positioned }, as: :assignable, class_name: 'Todo', inverse_of: :assignable
      has_many :intervention_type_todos, -> { intervention_types.positioned }, as: :assignable, class_name: 'Todo', inverse_of: :assignable

      has_many :activity_type_tasks, through: :activity_type_todos, source: :task, source_type: 'ActivityType'
      has_many :intervention_type_tasks, through: :intervention_type_todos, source: :task, source_type: 'InterventionType'

      accepts_nested_attributes_for :activity_type_todos, allow_destroy: true
      accepts_nested_attributes_for :intervention_type_todos, allow_destroy: true
    end
  end
end
