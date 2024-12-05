# == Schema Information
#
# Table name: todos
#
#  assignable_id   :bigint(8)        not null
#  assignable_type :string           not null
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  notes           :text
#  position        :integer          default(0), not null
#  task_id         :bigint(8)        not null
#  task_type       :string           not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_todos_on_assignable  (assignable_type,assignable_id)
#  index_todos_on_task        (task_type,task_id)
#
class Todo < ApplicationRecord
  belongs_to :assignable, polymorphic: true, optional: false
  belongs_to :task, polymorphic: true, optional: false

  scope :by_task_type, ->(type) { where(task_type: type) }
  scope :positioned, -> { order(position: :asc) }

  # belongs_to :activity_type, class_name: 'ActivityType'
  # belongs_to :intervention_type, class_name: 'InterventionType'

  delegated_type :assignable, types: %w[Audit ProgrammeType]
  delegated_type :task, types: %w[ActivityType InterventionType]

  has_many :completed_todos, dependent: :destroy, class_name: 'CompletedTodo', foreign_key: 'todo_id'

  def completed_todos_for(completable:)
    completed_todos.where(completable: completable) # order?
  end

  def complete!(completable:, recording:)
    if (completed_todo = completed_todos_for(completable:).last)
      completed_todo.update(recording: recording)
    else
      completed_todos_for(completable: completable).create!(recording: recording)
    end
  end

  def latest_recording(completable:)
    tasks_for(school: completable.school).in_academic_year_for(completable.school, Time.zone.now).by_date(:desc).first
  end

  private

  def task_for(school:)
    case task_type
    when 'Activity'
      school.activities.where(activity_type: task)
    when 'Observation'
      school.observations.intervention.where(intervention_type: task)
    else
      raise StandardError, 'Unsupported task type'
    end
  end
end
