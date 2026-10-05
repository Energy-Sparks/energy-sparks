# frozen_string_literal: true

FactoryBot.define do
  factory :intervention_type_aim, class: 'Activities::InterventionTypeAim' do
    intervention_type factory: %i[intervention_type]
    aim factory: %i[aim]
  end
end
