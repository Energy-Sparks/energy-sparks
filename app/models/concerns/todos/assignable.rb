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
      # can't have a pure tasks relationship - as would return mixed objects of mixed types

      accepts_nested_attributes_for :activity_type_todos, allow_destroy: true
      accepts_nested_attributes_for :intervention_type_todos, allow_destroy: true

      scope :with_task_type, ->(task_type) {
        where(id: ProgrammeType.joins(:todos).where(todos: { task_type: task_type.name }).distinct)
      }
    end

    def has_todos?
      todos.any?
    end

    def no_todos?
      todos.none?
    end

    # Has the provided school already completed all activity & intervention types this year?
    # regardless of having signed up to the programme
    def tasks_already_completed_for?(school:)
      task_count_for(school:) == todos.count
    end

    # activities completed regardless of programme / audit subscription
    def activity_types_already_completed_for(school:)
      activity_type_tasks.merge(school.activity_types_in_academic_year)
    end

    # actions completed regardless of programme / audit subscription
    def intervention_types_already_completed_for(school:)
      intervention_type_tasks.merge(school.intervention_types_in_academic_year)
    end

    # count of tasks already complete regardless of programme / audit subscription
    def task_count_for(school:)
      activity_types_already_completed_for(school:).length +
        intervention_types_already_completed_for(school:).length
    end

    def completable_for(school:)
      case self.class.to_s
      when 'ProgrammeType'
        school.programmes.active.not_abandoned.where(programme_type: self).in_reverse_start_order.first
      when 'Audit'
        self
      else
        raise StandardError, 'Unsupported completable type'
      end
    end
  end
end
