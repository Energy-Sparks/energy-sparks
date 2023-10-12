require 'rails_helper'

describe Amr::CheckingValidatedReadingsForAMeter do
  let(:start_date)            { Time.zone.today - 2 }
  let(:end_date)              { Time.zone.today }
  let(:expected_readings)     { 3 }
  let(:gas_dashboard_meter)   { build(:dashboard_gas_meter_with_validated_reading, start_date: start_date, end_date: end_date) }
  let(:upsert_gas_service)    { Amr::UpsertValidatedReadingsForAMeter.new(gas_dashboard_meter) }

  describe 'with a validated set of readings' do
    before(:each) do
      upsert_gas_service.perform
    end

    it 'removes data when appropriate' do
      expect(AmrValidatedReading.count).to eq expected_readings

      gas_dashboard_meter.amr_data.set_end_date(end_date - 1)

      upserted_meter_collection = upsert_gas_service.perform
      deleted = Amr::CheckingValidatedReadingsForAMeter.new(upserted_meter_collection).perform
      expect(deleted).to eq 1
      expect(AmrValidatedReading.count).to be expected_readings - 1
    end
  end
end
