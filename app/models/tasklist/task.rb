# == Schema Information
#
# Table name: tasklist_tasks
#
#  created_at             :datetime         not null
#  id                     :bigint(8)        not null, primary key
#  notes                  :text
#  position               :integer          default(0), not null
#  task_source_id       :bigint(8)        not null
#  task_source_type     :string           not null
#  tasklist_source_id   :bigint(8)        not null
#  tasklist_source_type :string           not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_tasklist_tasks_on_task_source      (task_source_type,task_source_id)
#  index_tasklist_tasks_on_tasklist_source  (tasklist_source_type,tasklist_source_id)
#
class Tasklist::Task < ApplicationRecord
  self.table_name = 'tasklist_tasks'
  belongs_to :tasklist_source, polymorphic: true, optional: false
  belongs_to :task_source, polymorphic: true, optional: false

  scope :by_task_type, ->(type) { where(task_source_type: type) }
  scope :positioned, -> { order(position: :asc) }

  # belongs_to :activity_type, class_name: 'ActivityType'
  # belongs_to :intervention_type, class_name: 'InterventionType'

  delegated_type :tasklist_source, types: %w[Audit ProgrammeType]
  delegated_type :task_source, types: %w[ActivityType InterventionType]

  has_many :tasklist_completed_tasks, dependent: :destroy, class_name: 'Tasklist::CompletedTask', foreign_key: 'tasklist_task_id'
end
