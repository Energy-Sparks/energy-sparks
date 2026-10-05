# frozen_string_literal: true

FactoryBot.define do
  factory :activity_type_topic, class: 'Activities::ActivityTypeTopic' do
    activity_type factory: %i[activity_type]
    topic factory: %i[topic]
  end
end
