# frozen_string_literal: true

# == Schema Information
#
# Table name: task_label_items
#
#  id         :bigint(8)        not null, primary key
#  task_type  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  label_id   :bigint(8)        not null
#  task_id    :bigint(8)        not null
#
# Indexes
#
#  index_task_label_items_on_label_id                            (label_id)
#  index_task_label_items_on_task                                (task_type,task_id)
#  index_task_label_items_on_task_type_and_task_id_and_label_id  (task_type,task_id,label_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (label_id => task_labels.id)
#
module Task
  class LabelItem < ApplicationRecord
    self.table_name = 'task_label_items'

    belongs_to :label, class_name: 'Task::Label'
    belongs_to :task, polymorphic: true, inverse_of: :label_items

    delegate :label_type, to: :label, allow_nil: true

    validates :label_id, uniqueness: { scope: %i[task_type task_id] }
    validates :label_type, inclusion: { in: ->(item) { item.task&.label_types || [] } }
  end
end
