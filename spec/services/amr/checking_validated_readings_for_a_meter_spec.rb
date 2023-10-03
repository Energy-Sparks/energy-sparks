require 'rails_helper'

describe Amr::CheckingValidatedReadingsForAMeter do

  let(:number_of_readings)    { 2 }
  let(:gas_dashboard_meter)   { build(:dashboard_gas_meter_with_validated_reading, reading_count: number_of_readings) }
  let(:upsert_gas_service)    { Amr::UpsertValidatedReadingsForAMeter.new(gas_dashboard_meter) }

  describe 'with a validated set of readings' do

    before(:each) do
      upsert_gas_service.perform
    end

    it 'removes data when appropriate' do
      expect(AmrValidatedReading.count).to be number_of_readings

      last_reading_date = gas_dashboard_meter.amr_data.keys.last
      gas_dashboard_meter.amr_data.set_end_date(last_reading_date - 1)

      upserted_meter_collection = upsert_gas_service.perform
      deleted = Amr::CheckingValidatedReadingsForAMeter.new(upserted_meter_collection).perform
      expect(deleted).to eq 1
      expect(AmrValidatedReading.count).to be number_of_readings - 1
    end
  end
end
