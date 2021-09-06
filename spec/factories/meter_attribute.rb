FactoryBot.define do
  factory :meter_attribute do
    attribute_type { :function_switch }
    input_data { 'heating_only' }
    association :meter, factory: :gas_meter
  end

  factory :storage_heaters_attribute, class: 'MeterAttribute' do
    attribute_type { :storage_heaters }
    input_data { {"start_date"=>"01/01/2010", "end_date"=>"01/01/2025", "power_kw"=>"70", "charge_start_time"=>{"hour"=>"0", "minutes"=>"0"}, "charge_end_time"=>{"hour"=>"24", "minutes"=>"0"}} }
    association :meter, factory: :electricity_meter
  end

end
