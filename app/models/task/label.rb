# frozen_string_literal: true

# == Schema Information
#
# Table name: task_labels
#
#  id         :bigint(8)        not null, primary key
#  label_type :enum             not null, enum_type: task_label_types
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Enums
#
#  task_label_types  aim, duration, topic, focus
#
module Task
  class Label < ApplicationRecord
    self.table_name = 'task_labels'

    extend Mobility

    translates :name, type: :string, fallbacks: { cy: :en }
    validates :name, presence: true, uniqueness: { scope: :label_type }

    enum :label_type, { aim: 'aim', duration: 'duration', topic: 'topic', focus: 'focus' }

    validates :label_type, presence: true

    has_many :label_items, class_name: 'Task::LabelItem', inverse_of: :label, dependent: :destroy
  end
end
