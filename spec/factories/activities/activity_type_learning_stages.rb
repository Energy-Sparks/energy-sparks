# frozen_string_literal: true

FactoryBot.define do
  factory :activity_type_learning_stage, class: 'Activities::ActivityTypeLearningStage' do
    activity_type factory: %i[activity_type]
    learning_stage factory: %i[learning_stage]
  end
end
