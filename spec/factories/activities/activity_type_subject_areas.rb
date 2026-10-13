# frozen_string_literal: true

FactoryBot.define do
  factory :activity_type_subject_area, class: 'Activities::ActivityTypeSubjectArea' do
    activity_type factory: %i[activity_type]
    subject_area factory: %i[subject_area]
  end
end
