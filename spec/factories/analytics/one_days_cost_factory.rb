# frozen_string_literal: true

FactoryBot.define do
  factory :one_days_cost, class: 'OneDaysCostData' do
    transient do
      rates_x48 do
        {
          'flat_rate' => Array.new(48) { rand(0.0..1.0).round(2) }
        }
      end
      standing_charges do
        { standing_charge: 1.0 }
      end
      differential     { false }
      system_wide      { false }
      default          { false }
      tariff           { nil }
    end

    initialize_with do
      new(rates_x48: rates_x48, standing_charges: standing_charges, differential: differential, system_wide: system_wide,
          default: default, tariff: tariff)
    end
  end
end
