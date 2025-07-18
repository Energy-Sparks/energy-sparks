# == Schema Information
#
# Table name: completed_todos
#
#  completable_id   :bigint(8)        not null
#  completable_type :string           not null
#  created_at       :datetime         not null
#  id               :bigint(8)        not null, primary key
#  recording_id     :bigint(8)        not null
#  recording_type   :string           not null
#  todo_id          :bigint(8)        not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_completed_todos_on_completable  (completable_type,completable_id)
#  index_completed_todos_on_recording    (recording_type,recording_id)
#  index_completed_todos_on_todo_id      (todo_id)
#
class CompletedTodo < ApplicationRecord
  belongs_to :todo, class_name: 'Todo'
  belongs_to :completable, polymorphic: true # such as Audit or Programme
  belongs_to :recording, polymorphic: true # such as ActivityType or InterventionType

  has_one :activity_type, through: :todo, source: :task, source_type: 'ActivityType'
  has_one :intervention_type, through: :todo, source: :task, source_type: 'InterventionType'

  validates :completable_id, uniqueness: { scope: :todo_id }

  scope :for, ->(completable:) { where(completable: completable).order(created_at: :desc) }

  scope :with_task_type, ->(task_type) { joins(:todo).where(todos: { task_type: task_type }) }
  scope :activity_types, -> { with_task_type('ActivityType') }
  scope :intervention_types, -> { with_task_type('InterventionType') }
end
