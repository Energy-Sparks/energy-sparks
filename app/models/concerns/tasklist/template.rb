module Tasklist
  module Template
    extend ActiveSupport::Concern

    included do
      has_many :tasklist_tasks, as: :tasklist_template, dependent: :destroy, class_name: 'Tasklist::Task', inverse_of: :tasklist_template
      has_many :tasklist_activity_types, through: :tasklist_tasks, source: :task_template, source_type: 'ActivityType'
      has_many :tasklist_intervention_types, through: :tasklist_tasks, source: :task_template, source_type: 'InterventionType'
      has_many :activity_type_tasks, -> { activity_types }, as: :tasklist_template, class_name: 'Tasklist::Task', inverse_of: :tasklist_template
      has_many :intervention_type_tasks, -> { intervention_types }, as: :tasklist_template, class_name: 'Tasklist::Task', inverse_of: :tasklist_template

      accepts_nested_attributes_for :tasklist_tasks, allow_destroy: true
      accepts_nested_attributes_for :activity_type_tasks, allow_destroy: true
      accepts_nested_attributes_for :intervention_type_tasks, allow_destroy: true
    end
  end
end
