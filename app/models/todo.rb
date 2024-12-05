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
    completed_todos.where(completable: completable)
  end

  def completed_todo_for(completable:)
    completed_todos_for(completable: completable).last
  end

  def complete!(completable:, recording:)
    if (completed_todo = completed_todo_for(completable:))
      completed_todo.update(recording: recording)
    else
      completed_todos_for(completable: completable).create!(recording: recording)
    end
  end

  def latest_recording_for_completable(completable)
    case completable.class
    when Audit
      ## For audit - consider all recordings made after audit created
      task_scope(completable.school).since(completable.created_at).by_date(:desc).first
    when Programme
      ## For programme, consider all recordings made in this academic year for school
      task_scope(completable.school).in_academic_year_for(completable.school, Time.zone.now).by_date(:desc).first
    else
      raise StandardError, 'Unsupported completable type'
    end
  end

  private

  def task_scope(school)
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
