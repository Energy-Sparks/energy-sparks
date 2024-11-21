# == Schema Information
#
# Table name: tasklist_tasks
#
#  created_at             :datetime         not null
#  id                     :bigint(8)        not null, primary key
#  notes                  :text
#  position               :integer          default(0), not null
#  task_template_id       :bigint(8)        not null
#  task_template_type     :string           not null
#  tasklist_template_id   :bigint(8)        not null
#  tasklist_template_type :string           not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_tasklist_tasks_on_task_template      (task_template_type,task_template_id)
#  index_tasklist_tasks_on_tasklist_template  (tasklist_template_type,tasklist_template_id)
#
class Tasklist::Task < ApplicationRecord
  self.table_name = 'tasklist_tasks'
  belongs_to :tasklist_template, polymorphic: true, optional: false
  belongs_to :task_template, polymorphic: true, optional: false # added own validation

  scope :by_task_type, ->(type) { where(task_template_type: type) }
  scope :positioned, -> { order(position: :asc) }

  # belongs_to :activity_type, class_name: 'ActivityType'
  # belongs_to :intervention_type, class_name: 'InterventionType'

  delegated_type :tasklist_template, types: %w[Audit ProgrammeType]
  delegated_type :task_template, types: %w[ActivityType InterventionType]

  has_many :tasklist_completed_tasks, dependent: :destroy, class_name: 'Tasklist::CompletedTask', foreign_key: 'tasklist_task_id'

  validate :task_template_presence

  private

  def task_template_presence
    # errors.add(:base, "#{task_template_type} must exist") if task_template.blank?
  end
end
