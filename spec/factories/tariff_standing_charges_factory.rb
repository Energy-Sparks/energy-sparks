FactoryBot.define do
  factory :tariff_standing_charge do
    association :meter, factory: :electricity_meter
    sequence(:start_date) { |n| Date.today - n.days }
    association :tariff_import_log, factory: :tariff_import_log
    value { rand(0.01...0.1) }
  end
end
