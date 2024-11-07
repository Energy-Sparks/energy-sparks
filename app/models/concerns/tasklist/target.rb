module Tasklist
  module Target
    extend ActiveSupport::Concern

    included do
      has_many :tasklist_completed_tasks, as: :tasklist_target, dependent: :destroy
      has_many :completed_tasks, through: :tasklist_completed_tasks, source: :tasklist_task
      has_many :completed_activity_types, through: :tasklist_completed_tasks, source: :activity_type
      has_many :completed_intervention_types, through: :tasklist_completed_tasks, source: :intervention_type
    end
  end
end
