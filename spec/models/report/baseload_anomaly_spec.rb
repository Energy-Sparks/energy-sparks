# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report::BaseloadAnomaly do
  subject(:anomaly) { described_class.first }

  let(:meter) { create(:electricity_meter) }

  let(:reading_date) { Date.yesterday }

  let(:previous_day_readings) { Array.new(48, 10.0) }
  let(:current_day_readings) { Array.new(48, 0.0) }

  before do
    create(:amr_validated_reading, meter: meter, reading_date: reading_date - 1, kwh_data_x48: previous_day_readings)
    create(:amr_validated_reading, meter: meter, reading_date: reading_date, kwh_data_x48: current_day_readings)
    described_class.refresh
  end

  def assert_result(anomaly, previous_date_average_baseload = nil, current_date_average_baseload = 0.0)
    expect(anomaly.meter).to eq(meter)
    expect(anomaly.reading_date).to eq(reading_date)
    expect(anomaly.previous_day_baseload).to be_within(0.0000001).of(previous_date_average_baseload) if previous_date_average_baseload
    expect(anomaly.today_baseload).to be_within(0.0000001).of(current_date_average_baseload)
  end

  context 'when identifying drops in baseload' do
    context 'with a large drop to zero' do
      it 'produces a result' do
        assert_result(anomaly, 20.0, 0.0)
      end
    end

    context 'with a large drop to near zero' do
      let(:current_day_readings) { Array.new(48, 0.004) }

      it 'produces a result' do
        assert_result(anomaly, 20.0, 0.008)
      end
    end

    context 'with a large drop but not to zero' do
      let(:current_day_readings) { Array.new(48, 1.0) }

      it 'produces a result' do
        assert_result(anomaly, 20.0, 2.0)
      end
    end

    context 'with a small drop to zero' do
      let(:previous_day_readings) { Array.new(48, 0.24) }

      it 'does not produce a result' do
        expect(anomaly).to be_nil
      end
    end

    context 'when both days are zero' do
      let(:previous_day_readings) { Array.new(48, 0.0) }

      it 'does not produce a result' do
        expect(anomaly).to be_nil
      end
    end
  end

  context 'when filtering readings' do
    let(:meter) { create(:gas_meter) }

    it 'only includes electricity meters' do
      expect(anomaly).to be_nil
    end

    context 'when filtering by date' do
      let(:analysis_date) { Time.zone.today - 30.days }

      it 'only includes readings from last 30 days' do
        expect(anomaly).to be_nil
      end
    end
  end

  context 'when calculating baseload' do
    # first 2 and last 2 hours are 0.2, rest are 0.1
    let(:current_day_readings) { Array.new(4, 0.2) + Array.new(40, 0.1) + Array.new(4, 0.2) }

    context 'when meter has no solar' do
      it 'calculates the statistical baseload correctly' do
        expect(anomaly.today_baseload).to be_within(0.0000001).of(0.2)
      end
    end

    context 'when meter has estimated solar' do
      before do
        create(:solar_pv_attribute, meter: meter)
        described_class.refresh
      end

      it 'calculates the overnight baseload correctly' do
        expect(anomaly.today_baseload).to be_within(0.0000001).of(0.4)
      end
    end

    context 'when meter has metered solar' do
      before do
        create(:solar_pv_mpan_meter_mapping, meter: meter)
        described_class.refresh
      end

      it 'calculates the overnight baseload correctly' do
        expect(anomaly.today_baseload).to be_within(0.0000001).of(0.4)
      end
    end

    context 'when meter has deleted solar_pv attribute' do
      before do
        create(:solar_pv_attribute, meter: meter, deleted_by: create(:admin))
        described_class.refresh
      end

      it 'calculates the statistical baseload correctly' do
        expect(anomaly.today_baseload).to be_within(0.0000001).of(0.2)
      end
    end
  end
end
