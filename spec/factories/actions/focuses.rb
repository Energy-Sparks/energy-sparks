# frozen_string_literal: true

FactoryBot.define do
  factory :focus, class: 'Actions::Focus' do
    sequence(:name) { |n| "Aim #{n}" }
  end
end
