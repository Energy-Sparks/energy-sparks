# frozen_string_literal: true

FactoryBot.define do
  factory :subject_area, class: 'Activities::SubjectArea' do
    sequence(:name) { |n| "Subject Area #{n}" }
    country { :england }
  end
end
