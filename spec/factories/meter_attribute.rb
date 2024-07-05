FactoryBot.define do
  factory :meter_attribute do
    attribute_type { :function_switch }
    input_data { 'heating_only' }
    association :meter, factory: :gas_meter
    replaces { nil }

    trait :replaced do
      replaced_by { create(:meter_attribute) }
    end

    trait :deleted do
      replaced
      deleted_by { create(:admin) }
    end

    trait :heating_only do
      attribute_type { 'function_switch' }
      input_data { 'heating_only' }
    end

    trait :kitchen_only do
      attribute_type { 'function_switch' }
      input_data { 'kitchen_only' }
    end

    trait :hotwater_only do
      attribute_type { 'function_switch' }
      input_data { 'hotwater_only' }
    end

    trait :aggregation_switch do
      attribute_type { 'aggregation_switch' }
      input_data { 'ignore_start_date' }
    end
  end

  factory :storage_heaters_attribute, class: 'MeterAttribute' do
    attribute_type { :storage_heaters }
    input_data { { 'start_date' => '01/01/2010', 'end_date' => '01/01/2025', 'power_kw' => '70', 'charge_start_time' => { 'hour' => '0', 'minutes' => '0' }, 'charge_end_time' => { 'hour' => '24', 'minutes' => '0' } } }
    association :meter, factory: :electricity_meter
  end

  factory :solar_pv_attribute, class: 'MeterAttribute' do
    transient do
      start_date    { '01/01/2023' }
      end_date      { '01/01/2024' }
      kwp           { 15.0 }
    end
    attribute_type { :solar_pv }
    association :meter, factory: :electricity_meter
    input_data do
      {
        start_date: start_date,
        end_date: end_date,
        kwp: kwp
      }
    end
  end
end
