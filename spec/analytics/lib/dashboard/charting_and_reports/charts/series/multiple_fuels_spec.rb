# frozen_string_literal: true

require 'rails_helper'

describe Series::MultipleFuels do
  subject(:series_manager) do
    described_class.new(meter_collection, chart_config)
  end

  let(:electricity) do
    build(:meter,
          meter_collection: meter_collection,
          type: :electricity,
          amr_data: build(:amr_data, :with_date_range, type: :electricity,
                                                       start_date: Date.new(2022, 1, 1),
                                                       end_date: Date.new(2022, 12, 31)))
  end

  let(:gas) do
    build(:meter,
          meter_collection: meter_collection,
          type: :electricity,
          amr_data: build(:amr_data, :with_date_range, type: :electricity,
                                                       start_date: Date.new(2022, 1, 1),
                                                       end_date: Date.new(2023, 12, 31)))
  end

  let(:meter_collection) { build(:meter_collection) }

  let(:chart_config) do
    {
      meter_definition: :all,
      series_breakdown: :fuel
    }
  end

  before do
    meter_collection.add_electricity_meter(electricity)
    meter_collection.add_heat_meter(gas)
    AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters
  end

  describe '#day_breakdown' do
    context 'when retrieving data for a date covered by both meters' do
      it 'returns data' do
        breakdown = series_manager.day_breakdown(Date.new(2022, 1, 1), Date.new(2022, 1, 1))
        expect(breakdown.keys).to match_array(%w[electricity gas])
        expect(breakdown.values.all? { |v| v > 0.0 }).to be true
      end
    end

    context 'when retrieving data for period covered by only one meter' do
      it 'returns data' do
        breakdown = series_manager.day_breakdown(Date.new(2023, 1, 1), Date.new(2023, 1, 1))
        expect(breakdown.keys).to match_array(%w[electricity gas])
        expect(breakdown['gas']).not_to eq(0.0)
        expect(breakdown['electricity']).to eq(0.0) # has limited data
      end
    end
  end
end
