# frozen_string_literal: true

FactoryBot.define do
  factory :topic, class: 'Activities::Topic' do
    sequence(:name) { |n| "Topic #{n}" }
  end
end
