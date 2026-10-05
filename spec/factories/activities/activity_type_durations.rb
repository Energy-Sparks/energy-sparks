# frozen_string_literal: true

FactoryBot.define do
  factory :activity_type_duration, class: 'Activities::ActivityTypeDuration' do
    activity_type factory: %i[activity_type]
    duration factory: %i[duration]
  end
end
