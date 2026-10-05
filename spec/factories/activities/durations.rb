# frozen_string_literal: true

FactoryBot.define do
  factory :duration, class: 'Activities::Duration' do
    sequence(:name) { |n| "Duration #{n}" }
  end
end
