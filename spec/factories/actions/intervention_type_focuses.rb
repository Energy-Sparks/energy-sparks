# frozen_string_literal: true

FactoryBot.define do
  factory :intervention_type_focus, class: 'Actions::InterventionTypeFocus' do
    intervention_type factory: %i[intervention_type]
    focus factory: %i[focus]
  end
end
