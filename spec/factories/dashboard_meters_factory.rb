require 'dashboard'

FactoryBot.define do
  factory :dashboard_gas_meter, class: 'Dashboard::Meter' do
    transient do
      school
      sequence(:mpan_mprn)  { |n| n }
      sequence(:name)       { |n| "meter-#{n}" }
      meter_type            { :gas }
      active                { true }
    end

    initialize_with { Dashboard::Meter.new(type: meter_type, identifier: mpan_mprn, name: name, meter_collection: school, amr_data: nil) }

    factory :dashboard_gas_meter_with_validated_reading do
      transient do
        reading_count       { 1 }
        start_reading_date  { Date.today - reading_count.days }
        config              { create(:amr_data_feed_config) }
        actual_meter        { create(:gas_meter) }
      end

      after(:build) do |meter, evaluator|
        meter.external_meter_id = evaluator.actual_meter.id
        readings = evaluator.reading_count.times.map { |index| build(:dashboard_one_day_amr_reading, dashboard_meter: meter, date: evaluator.start_reading_date + index) }
        meter.amr_data=AMRData.new(:gas)
        readings.each { |r| meter.amr_data.add(r.date, r) }
      end
    end

    factory :dashboard_electricity_meter, class: 'Dashboard::Meter' do
      transient do
        meter_type { :electricity }
      end

      factory :dashboard_electricity_meter_with_validated_reading do
        transient do
          reading_count       { 1 }
          start_reading_date  { Date.today - reading_count.days }
          config              { create(:amr_data_feed_config) }
          actual_meter        { create(:electricity_meter) }
        end

        after(:build) do |meter, evaluator|
          meter.external_meter_id = evaluator.actual_meter.id
          readings = evaluator.reading_count.times.map { |index| build(:dashboard_one_day_amr_reading, dashboard_meter: meter, date: evaluator.start_reading_date + index) }
          meter.amr_data=AMRData.new(:electricity)
          readings.each { |r| meter.amr_data.add(r.date, r) }
        end
      end
    end
  end
end
