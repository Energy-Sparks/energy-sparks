# frozen_string_literal: true

FactoryBot.define do
  factory :learning_stage do
    sequence(:name) { |n| "Learning Stage #{n}" }
    sequence(:abbreviation) { |n| "LS#{n}" }
    country { :england }
  end
end
