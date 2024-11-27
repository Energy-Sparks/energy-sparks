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
  belongs_to :completable, polymorphic: true
  belongs_to :recording, polymorphic: true

  has_one :activity_type, through: :todo, source: :task, source_type: 'ActivityType'
  has_one :intervention_type, through: :todo, source: :task, source_type: 'InterventionType'
end
