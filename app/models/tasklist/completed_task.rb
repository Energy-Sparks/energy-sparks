# == Schema Information
#
# Table name: tasklist_completed_tasks
#
#  created_at             :datetime         not null
#  happened_on            :datetime
#  id                     :bigint(8)        not null, primary key
#  task_instance_id       :bigint(8)        not null
#  task_instance_type     :string           not null
#  tasklist_instance_id   :bigint(8)        not null
#  tasklist_instance_type :string           not null
#  tasklist_task_id       :bigint(8)        not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_tasklist_completed_tasks_on_task_instance      (task_instance_type,task_instance_id)
#  index_tasklist_completed_tasks_on_tasklist_instance  (tasklist_instance_type,tasklist_instance_id)
#  index_tasklist_completed_tasks_on_tasklist_task_id   (tasklist_task_id)
#
class Tasklist::CompletedTask < ApplicationRecord
  self.table_name = 'tasklist_completed_tasks'
  belongs_to :tasklist_task, class_name: 'Tasklist::Task'

  belongs_to :tasklist_instance, polymorphic: true
  belongs_to :task_instance, polymorphic: true

  has_one :activity_type, through: :tasklist_task, source: :task_template, source_type: 'ActivityType'
  has_one :intervention_type, through: :tasklist_task, source: :task_template, source_type: 'InterventionType'
end
