# frozen_string_literal: true

require 'rails_helper'

describe Series::MeterBreakdown do
  subject(:series_manager) do
    Series::MeterBreakdown.new(meter_collection, chart_config)
  end

  let(:meters) { build_list(:meter, 3) }
  let(:meter_collection) { build(:meter_collection, :with_aggregate_meter, :with_electricity_meters, meters: meters) }

  let(:chart_config) do
    {
      meter_definition: :allelectricity,
      series_breakdown: :meter
    }
  end

  describe '#series_name' do
    context 'when meters have unique names' do
      it 'uses meter series names' do
        expect(series_manager.series_names).to match_array(meters.map(&:series_name))
      end
    end

    context 'when meters have duplicate names' do
      let(:meter_1) { build(:meter, name: 'Duplicate') }
      let(:meter_2) { build(:meter, name: 'Duplicate') }
      let(:meter_3) { build(:meter) }
      let(:meters)  { [meter_1, meter_2, meter_3] }

      it 'adjusts the individual series names' do
        expect(series_manager.series_names).to contain_exactly(meter_1.qualified_series_name, meter_2.qualified_series_name, meter_3.series_name)
      end
    end
  end
end
