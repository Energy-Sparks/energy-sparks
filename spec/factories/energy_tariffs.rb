FactoryBot.define do
  factory :energy_tariff do
    sequence(:name) {|n| "Energy Tariff #{n}"}
    start_date { '2020-01-01' }
    end_date { '2022-12-31' }
    meter_type { :electricity }
    source { :manually_entered }
    tariff_type { :flat_rate }
    tariff_holder { create(:school) }
    created_by { association :user }
    updated_by { association :user }
  end
end
