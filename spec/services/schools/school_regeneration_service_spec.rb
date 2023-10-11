require 'rails_helper'

describe Schools::SchoolRegenerationService, type: :service do
  subject(:service)       { Schools::SchoolRegenerationService.new(school: school, logger: logger) }

  let(:school)            { create(:school) }

  let(:logger)            { double(Rails.logger) }

  # this will create an empty meter collection as the school has no data
  let(:meter_collection)  { Amr::AnalyticsMeterCollectionFactory.new(school).validated }

  before do
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
  end

  describe '#perform' do
    before do
      expect_any_instance_of(Amr::ValidateAndPersistReadingsService).to receive(:perform).and_return(meter_collection)
      expect_any_instance_of(AggregateDataService).to receive(:aggregate_heat_and_electricity_meters)
      expect_any_instance_of(AggregateSchoolService).to receive(:cache)
      expect_any_instance_of(Schools::SchoolMetricsGeneratorService).to receive(:perform)
    end

    it 'calls validate, update cache and regenerate metrics ' do
      service.perform
    end
  end
end
