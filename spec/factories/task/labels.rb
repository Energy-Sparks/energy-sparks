# frozen_string_literal: true

FactoryBot.define do
  factory :label, class: 'Task::Label' do
    sequence(:name) { |n| "Label #{n}" }
    label_type { :aim }
  end
end
