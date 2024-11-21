# == Schema Information
#
# Table name: tasklist_completed_tasks
#
#  created_at           :datetime         not null
#  happened_on          :datetime
#  id                   :bigint(8)        not null, primary key
#  task_target_id       :bigint(8)        not null
#  task_target_type     :string           not null
#  tasklist_target_id   :bigint(8)        not null
#  tasklist_target_type :string           not null
#  tasklist_task_id     :bigint(8)        not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_tasklist_completed_tasks_on_task_target       (task_target_type,task_target_id)
#  index_tasklist_completed_tasks_on_tasklist_target   (tasklist_target_type,tasklist_target_id)
#  index_tasklist_completed_tasks_on_tasklist_task_id  (tasklist_task_id)
#
class Tasklist::CompletedTask < ApplicationRecord
  self.table_name = 'tasklist_completed_tasks'
  belongs_to :tasklist_task, class_name: 'Tasklist::Task'

  belongs_to :tasklist_target, polymorphic: true
  belongs_to :task_target, polymorphic: true

  has_one :activity_type, through: :tasklist_task, source: :task_source, source_type: 'ActivityType'
  has_one :intervention_type, through: :tasklist_task, source: :task_source, source_type: 'InterventionType'
end
