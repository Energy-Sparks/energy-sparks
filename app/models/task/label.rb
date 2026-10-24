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
    include Deletable

    ACTIVITY_TYPES = %i[aim duration topic].freeze
    ACTION_TYPES = %i[focus].freeze
    TASK_TYPES = ACTIVITY_TYPES.index_with('activity').merge(ACTION_TYPES.index_with('action')).freeze

    translates :name, type: :string, fallbacks: { cy: :en }
    enum :label_type, (ACTIVITY_TYPES + ACTION_TYPES).index_with(&:to_s)

    validates :name, presence: true, uniqueness: { scope: :label_type }
    validates :label_type, presence: true

    has_many :label_items, class_name: 'Task::LabelItem', inverse_of: :label, dependent: :destroy

    scope :of_type, ->(label_type) { where(label_type: label_type) }
    scope :by_name, -> { order(name: :asc) }

    def task_type
      self.class.task_type(label_type)
    end

    def self.task_type(label_type)
      TASK_TYPES[label_type.to_s.to_sym]
    end

    def deletable?
      label_items.empty?
    end

    private

    def destroy_error_message
      'This label is in use and cannot be deleted'
    end
  end
end
