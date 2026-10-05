# frozen_string_literal: true

FactoryBot.define do
  factory :aim, class: 'Activities::Aim' do
    sequence(:name) { |n| "Aim #{n}" }
  end
end
