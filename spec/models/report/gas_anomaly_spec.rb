# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report::GasAnomaly do
  subject(:anomaly) { described_class.first }

  let(:meter) do
    school = create(:school, :with_school_group, :with_calendar,
               weather_station: create(:weather_station))
    create(:gas_meter, school: school)
  end

  let(:previous_day_event_type) { nil }
  let(:current_day) { Date.yesterday }
  let(:previous_day_kwh) { 1.0 }
  let(:previous_day_temperature) { Array.new(48, rand(15.0..16.0)) }

  before do
    previous_day = current_day - 7.days
    create(:weather_observation,
           weather_station: meter.school.weather_station,
           reading_date: current_day,
           temperature_celsius_x48: Array.new(48, rand(15.0..16.0)))
    create(:weather_observation,
           weather_station: meter.school.weather_station,
           reading_date: previous_day,
           temperature_celsius_x48: previous_day_temperature)

    event_type = create(:calendar_event_type, :term_time)
    create(:calendar_event,
           calendar: meter.school.calendar,
           calendar_event_type: event_type,
           start_date: current_day, end_date: current_day)
    create(:calendar_event,
           calendar: meter.school.calendar,
           calendar_event_type: previous_day_event_type || event_type,
           start_date: previous_day, end_date: previous_day)

    create(:amr_validated_reading, meter: meter, reading_date: current_day, one_day_kwh: 500.0)
    create(:amr_validated_reading, meter: meter, reading_date: previous_day, one_day_kwh: previous_day_kwh)

    described_class.refresh
  end

  it 'returns the expected results' do
    expect(anomaly.meter).to eq(meter)
    expect(anomaly.reading_date).to eq(current_day)
    expect(anomaly.today_kwh).to eq(500.0)
    expect(anomaly.previous_kwh).to eq(previous_day_kwh)
  end

  context 'when filtering readings' do
    context 'with an electriciy meter' do
      let(:meter) { create(:electricity_meter) }

      it 'only includes gas meters' do
        expect(anomaly).to be_nil
      end
    end

    context 'when previous day usage was zero' do
      let(:previous_day_kwh) { 0.0 }

      it 'ignores the day' do
        expect(anomaly).to be_nil
      end
    end

    context 'when previous day usage was similar' do
      let(:previous_day_kwh) { 499.0 }

      it 'ignores the day' do
        expect(anomaly).to be_nil
      end
    end

    context 'when previous day temperature was lower' do
      let(:previous_day_temperature) { Array.new(48, rand(0.0..2.0)) }

      it 'only compares dates with same type' do
        expect(anomaly).to be_nil
      end
    end

    context 'when previous day was in a holiday' do
      let(:previous_day_event_type) { create(:calendar_event_type, :holiday) }

      it 'only compares dates with same type' do
        expect(anomaly).to be_nil
      end
    end

    context 'when filtering by date' do
      let(:current_day) { Time.zone.today - 1.year }

      it 'only includes readings from last 60 days' do
        expect(anomaly).to be_nil
      end
    end
  end
end
