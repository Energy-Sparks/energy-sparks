require 'dashboard'

FactoryBot.define do
  factory :dashboard_gas_meter, class: 'Dashboard::Meter' do
    transient do
      school
      sequence(:mpan_mprn)  { |n| n }
      sequence(:name)       { |n| "meter-#{n}" }
      meter_type            { :gas }
      active                { true }
      amr_data              { AMRData.new(:test) }
    end

    initialize_with { Dashboard::Meter.new(type: meter_type, identifier: mpan_mprn, name: name, meter_collection: school, amr_data: amr_data) }

    factory :dashboard_gas_meter_with_validated_reading do
      transient do
        reading_count       { 1 }
        start_date          { Time.zone.today - reading_count }
        end_date            { Time.zone.today }
        actual_meter        { create(:gas_meter) }
        status              { 'ORIG' }
        substitute_date     { nil }
        upload_datetime     { Time.zone.today }
        kwh_data_x48        { Array.new(48, rand.to_f) }
      end

      after(:build) do |meter, evaluator|
        meter.external_meter_id = evaluator.actual_meter.id
        (evaluator.start_date.to_date..evaluator.end_date.to_date).each do |date|
          reading = build(:dashboard_one_day_amr_reading,
                      dashboard_meter: meter,
                      date: date,
                      status: evaluator.status,
                      substitute_date: evaluator.substitute_date,
                      upload_datetime: evaluator.upload_datetime,
                      kwh_data_x48: evaluator.kwh_data_x48)
          meter.amr_data.add(date, reading)
        end
      end
    end

    factory :dashboard_electricity_meter, class: 'Dashboard::Meter' do
      transient do
        meter_type { :electricity }
      end

      factory :dashboard_electricity_meter_with_validated_reading do
        transient do
          reading_count       { 1 }
          start_reading_date  { Time.zone.today - reading_count.days }
          actual_meter        { create(:electricity_meter) }
        end

        after(:build) do |meter, evaluator|
          meter.external_meter_id = evaluator.actual_meter.id
          readings = evaluator.reading_count.times.map { |index| build(:dashboard_one_day_amr_reading, dashboard_meter: meter, date: evaluator.start_reading_date + index) }
          readings.each { |r| meter.amr_data.add(r.date, r) }
        end
      end
    end
  end
end
