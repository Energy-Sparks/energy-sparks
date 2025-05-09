# frozen_string_literal: true

require 'rails_helper'

describe Series::SubMeterBreakdown do
  subject(:series_manager) do
    Series::SubMeterBreakdown.new(meter_collection, chart_config)
  end

  let(:meters)      { build_list(:meter, 3) }
  let(:sub_meters)  { {} }
  let(:meter_collection) { build(:meter_collection, :with_electricity_meters, :with_sub_meters, meters: meters, sub_meters: sub_meters) }

  let(:chart_config) do
    {
      meter_definition: :allelectricity,
      series_breakdown: :meter
    }
  end

  describe '#series_name' do
    context 'when there are no sub_meters' do
      let(:sub_meters) { { mains_consume: build(:meter) } }

      it 'uses meter series names' do
        expect(series_manager.series_names).to match_array(sub_meters.values.map(&:series_name))
      end
    end

    context 'when there are solar sub_meters' do
      let(:sub_meters) do
        {
          mains_consume: build(:meter),
          generation: build(:meter),
          self_consume: build(:meter),
          export: build(:meter)
        }
      end

      it 'uses all meter series names' do
        expect(series_manager.series_names).to match_array(sub_meters.values.map(&:series_name))
      end
    end
  end
end
