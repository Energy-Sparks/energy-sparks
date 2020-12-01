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
      end

      after(:build) do |meter, evaluator|
        actual_meter = create(:gas_meter)
        meter.external_meter_id = actual_meter.id
        readings = evaluator.reading_count.times.map { |index| build(:dashboard_one_day_amr_reading, dashboard_meter: meter, date: evaluator.start_reading_date + index) }
        # meter.amr_data = readings.map { |a| [a.date, a]}.to_h
        meter.amr_data=AMRData.new(:blah)
        readings.each { |a| meter.amr_data[a.date] = a }
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
        end

        after(:build) do |meter, evaluator|
          actual_meter = create(:electricity_meter)
          meter.external_meter_id = actual_meter.id
          readings = evaluator.reading_count.times.map { |index| build(:dashboard_one_day_amr_reading, dashboard_meter: meter, date: evaluator.start_reading_date + index) }
          meter.amr_data = readings.map { |a| [a.date, a]}.to_h
        end
      end
    end
  end
end
