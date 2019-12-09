require 'rails_helper'

describe Amr::UpsertValidatedReadingsForAMeter do

  let(:number_of_readings)    { 2 }
  let(:gas_dashboard_meter)   { build(:dashboard_gas_meter_with_validated_reading, reading_count: number_of_readings) }
  let(:upsert_gas_service)    { Amr::UpsertValidatedReadingsForAMeter.new(gas_dashboard_meter) }

  describe 'with a validated set of readings' do

    before(:each) do
      upsert_gas_service.perform
    end

    it 'inserts with new data' do
      expect(AmrValidatedReading.count).to be number_of_readings
    end

    it 'upserts data' do
      latest_reading = AmrValidatedReading.order(reading_date: :desc).first
      previous_total = latest_reading.one_day_kwh

      new_amr_data = build(:dashboard_one_day_amr_reading, dashboard_meter: gas_dashboard_meter, date: latest_reading.reading_date)
      new_total = new_amr_data.one_day_kwh

      expect(new_total).to_not eq previous_total
      gas_dashboard_meter.amr_data[latest_reading.reading_date] = new_amr_data

      Amr::UpsertValidatedReadingsForAMeter.new(gas_dashboard_meter).perform

      expect(AmrValidatedReading.count).to be number_of_readings
      expect(AmrValidatedReading.find_by(reading_date: latest_reading.reading_date).one_day_kwh).to eq BigDecimal(new_total, 15)
    end
  end

  describe 'with a duff set of readings' do
    it 'does not insert duff data' do
      last_reading_date = gas_dashboard_meter.amr_data.keys.last
      last_reading = gas_dashboard_meter.amr_data[last_reading_date]

      new_amr_data = build(:dashboard_one_day_amr_reading, dashboard_meter: gas_dashboard_meter, date: last_reading_date, kwh_data_x48: Array.new(48, Float::NAN), one_day_kwh: Float::NAN)

      gas_dashboard_meter.amr_data[last_reading_date] = new_amr_data

      upsert_gas_service.perform

      expect(AmrValidatedReading.count).to be number_of_readings - 1
      expect(AmrValidatedReading.find_by(reading_date: last_reading_date)).to be nil
    end
  end
end
