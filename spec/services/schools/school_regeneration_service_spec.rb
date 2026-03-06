# frozen_string_literal: true

require 'rails_helper'

describe Schools::SchoolRegenerationService, type: :service do
  subject(:service) do
    service = described_class.new(school:, logger: instance_double(Logger, info: nil, warn: nil, error: nil))
    allow(Amr::ValidateAndPersistReadingsService).to receive(:new).and_return(readings_service)
    allow(AggregateDataService).to receive(:new).and_return(aggregate_data_service)
    allow(Schools::SchoolMetricsGeneratorService).to receive(:new).and_return(school_metrics_generator)
    allow(AggregateSchoolService).to receive(:new).and_return(aggregate_school_service)
    allow(Amr::AnalyticsMeterCollectionFactory).to receive(:new).and_return(meter_collection_factory)
    service
  end

  let(:school) { create(:school) }
  let(:readings_service) { instance_double(Amr::ValidateAndPersistReadingsService, perform: nil) }
  let(:aggregate_data_service) { instance_double(AggregateDataService, aggregate_heat_and_electricity_meters: nil) }
  let(:school_metrics_generator) { instance_double(Schools::SchoolMetricsGeneratorService, perform: nil) }
  let(:aggregate_school_service) { instance_double(AggregateSchoolService, cache: nil, invalidate_cache: nil) }
  let(:meter_collection_factory) { instance_double(Amr::AnalyticsMeterCollectionFactory, validated: nil) }

  describe '#perform' do
    context 'when there are no errors' do
      it 'validates, updates cache and regenerates metrics' do
        expect(service.perform).to be true
        expect(readings_service).to have_received(:perform)
        expect(meter_collection_factory).not_to have_received(:validated)
        expect(aggregate_data_service).to have_received(:aggregate_heat_and_electricity_meters)
        expect(aggregate_school_service).to have_received(:cache)
        expect(aggregate_school_service).not_to have_received(:invalidate_cache)
        expect(school_metrics_generator).to have_received(:perform)
      end
    end

    context 'when validation fails' do
      before { allow(readings_service).to receive(:perform).and_raise(exception) }

      def expect_correct_mocks_called
        expect(meter_collection_factory).to have_received(:validated)
        expect(aggregate_data_service).to have_received(:aggregate_heat_and_electricity_meters)
        expect(aggregate_school_service).to have_received(:cache)
        expect(aggregate_school_service).not_to have_received(:invalidate_cache)
        expect(school_metrics_generator).to have_received(:perform)
      end

      context 'with a standard exception' do
        let(:exception) { StandardError }

        it 'continues' do
          expect(service.perform).to be true
          expect_correct_mocks_called
          expect(school.regeneration_errors.pluck(:message)).to eq([])
        end
      end

      context 'with EnergySparksUnexpectedStateException' do
        let(:exception) { EnergySparksUnexpectedStateException.new('test') }

        it 'continues and records an error' do
          expect(service.perform).to be true
          expect_correct_mocks_called
          expect(school.regeneration_errors.pluck(:message)).to eq(['test'])
        end
      end
    end

    context 'when aggregation fails' do
      before do
        allow(aggregate_data_service).to receive(:aggregate_heat_and_electricity_meters).and_raise
      end

      it 'invalidates cache and does not regenerate metrics' do
        expect(service.perform).to be false
        expect(meter_collection_factory).not_to have_received(:validated)
        expect(aggregate_school_service).not_to have_received(:cache)
        expect(aggregate_school_service).to have_received(:invalidate_cache)
        expect(school_metrics_generator).not_to have_received(:perform)
      end
    end
  end
end
