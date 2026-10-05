# frozen_string_literal: true

FactoryBot.define do
  factory :activity_type_aim, class: 'Activities::ActivityTypeAim' do
    activity_type factory: %i[activity_type]
    aim factory: %i[aim]
  end
end
