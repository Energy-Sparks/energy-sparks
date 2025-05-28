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
  belongs_to :assignable, polymorphic: true
  belongs_to :task, polymorphic: true
  has_many :completed_todos, dependent: :destroy

  scope :activity_types, -> { where(task_type: 'ActivityType') }
  scope :intervention_types, -> { where(task_type: 'InterventionType') }

  scope :by_task_type, ->(type) { where(task_type: type) }
  scope :positioned, -> { order(position: :asc) }

  delegated_type :assignable, types: %w[Audit ProgrammeType]
  delegated_type :task, types: %w[ActivityType InterventionType]

  # todo.complete!(completable: Programme/Audit, recording: Activity/Obervation)
  def complete!(completable:, recording:)
    # There should only ever be one but pick last one created just in case
    completed_todos.for(completable: completable).first_or_initialize.update!(recording: recording)
  end

  # todo.recording_for(completable: Programme/Audit)
  # Returns recording for todo item
  def recording_for(completable:)
    completed_todos.for(completable: completable).last&.recording
  end

  # todo.complete?(completable: Programme/Audit)
  def complete_for?(completable:)
    completed_todos.for(completable: completable).any?
  end

  def latest_recording_for(completable:)
    recordings_for(school: completable.school).in_academic_year_for(completable.school, Time.zone.now).by_date(:asc).order(id: :asc).last
  end

  private

  def recordings_for(school:)
    case task_type
    when 'ActivityType'
      school.activities.where(activity_type: task)
    when 'InterventionType'
      school.observations.intervention.visible.where(intervention_type: task)
    else
      raise StandardError, 'Unsupported task type'
    end
  end
end
