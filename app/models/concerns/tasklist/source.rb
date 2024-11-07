module Tasklist
  module Source
    extend ActiveSupport::Concern

    included do
      has_many :tasklist_tasks, as: :tasklist_source, dependent: :destroy
      has_many :tasklist_activity_types, through: :tasklist_tasks, source: :task_source, source_type: 'ActivityType'
      has_many :tasklist_intervention_types, through: :tasklist_tasks, source: :task_source, source_type: 'InterventionType'
    end
  end
end
