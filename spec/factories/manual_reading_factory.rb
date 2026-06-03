# frozen_string_literal: true

FactoryBot.define do
  factory :manual_reading, class: 'Schools::ManualReading' do
    month { Date.current.beginning_of_month }
    school
  end
end
