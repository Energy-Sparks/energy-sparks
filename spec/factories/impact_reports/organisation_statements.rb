# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_organisation_statement, class: 'ImpactReport::OrganisationStatement' do
    sequence(:academic_year) { |n| "Academic Year #{n}" }
    sequence(:efficiency_report_link) { |n| "https://example.org/#{n}" }
    current { false }

    schools { rand(100..1000) }
    pupils { rand(20_000..100_000) }
    staff { rand(1..1000) }
    activities { rand(1000..10_000) }
    actions { rand(1000..10_000) }
    total_cost_savings { rand(1_000_000..10_000_000) }
    total_carbon_savings { rand(1..1000) }

    average_primary_saving { rand(1..100) }
    average_secondary_saving { rand(1..100) }
    best_saving { rand(1..100) }

    primary_saving_electricity { rand(1..100) }
    primary_saving_gas { rand(1..100) }
    primary_cost_saving { rand(100..10_000) }
    primary_carbon_saving { rand(100..10_000) }

    secondary_saving_electricity { rand(1..100) }
    secondary_saving_gas { rand(1..100) }
    secondary_cost_saving { rand(100..10_000) }
    secondary_carbon_saving { rand(100..10_000) }

    trait :current do
      current { true }
    end
  end
end
