# == Schema Information
#
# Table name: tasklist_tasks
#
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  notes                :text
#  position             :integer          default(0), not null
#  task_source_id       :bigint(8)        not null
#  task_source_type     :string           not null
#  tasklist_source_id   :bigint(8)        not null
#  tasklist_source_type :string           not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_tasklist_tasks_on_task_source      (task_source_type,task_source_id)
#  index_tasklist_tasks_on_tasklist_source  (tasklist_source_type,tasklist_source_id)
#
class TasklistTask < ApplicationRecord
  belongs_to :tasklist_source, polymorphic: true
  belongs_to :task_source, polymorphic: true, optional: true

  # belongs_to :activity_type, class_name: 'ActivityType'
  # belongs_to :intervention_type, class_name: 'InterventionType'

  delegated_type :tasklist_source, types: %w[Audit ProgrammeType]
  delegated_type :task_source, types: %w[ActivityType InterventionType]

  # NEW - check works!
  has_one :tasklist_completed_task, dependent: :destroy

  validate :task_source_presence

  private

  def task_source_presence
    errors.add(:base, "#{task_source_type} must exist") if task_source.blank?
  end
end
