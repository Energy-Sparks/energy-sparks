# frozen_string_literal: true

FactoryBot.define do
  factory :label_item, class: 'Task::LabelItem' do
    label factory: %i[label]
    task factory: %i[activity_type]
  end
end
