require 'rails_helper'

describe Amr::ValidateAndPersistReadingsService, type: :service do
  subject(:service)       { Amr::ValidateAndPersistReadingsService.new(school, logger) }

  let(:school)            { create(:school) }
  let!(:meter)            { create(:gas_meter_with_reading, school: school) }
  let(:logger)            { double(Rails.logger) }

  let(:meter_collection)  { double('meter-collection') }

  before do
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
    allow(meter_collection).to receive(:heat_meters).and_return([])
    allow(meter_collection).to receive(:electricity_meters).and_return([])
  end

  describe '#perform' do
    before do
      expect_any_instance_of(Amr::AnalyticsMeterCollectionFactory).to receive(:unvalidated).and_return(meter_collection)
      expect_any_instance_of(AggregateDataService).to receive(:validate_meter_data).and_return(meter_collection)
      expect_any_instance_of(Amr::UpsertValidatedReadings).to receive(:perform)
    end

    it 'creates meter collection, validates data and updates the database' do
      service.perform
    end
  end
end
