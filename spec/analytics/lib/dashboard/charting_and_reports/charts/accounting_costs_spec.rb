# frozen_string_literal: true

require 'rails_helper'

describe Series::AccountingCost do
  let(:meter_definition) { :allelectricity_unmodified }
  let(:chart_config) do
    {
      chart1_type: :column,
      ignore_single_series_failure: true,
      meter_definition: meter_definition,
      name: 'Energy Costs',
      series_breakdown: :accounting_cost,
      timescale: [
        {
          up_to_a_year: 0
        },
        {
          up_to_a_year: -1
        }
      ],
      x_axis: :month,
      yaxis_scaling: :none,
      yaxis_units: :accounting_cost
    }
  end

  let(:original_meter)              { double('original-meter') }
  let(:electricity_aggregate_meter) { double('electricity-aggregated-meter') }
  let(:meter_collection)            { double('meter-collection') }

  let(:accounting_cost_series)      { described_class.new(meter_collection, chart_config) }

  before do
    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)
    allow(electricity_aggregate_meter).to receive(:original_meter).and_return(original_meter)
  end

  context 'when original unmodified chart config' do
    it 'returns original meter from aggregate electricity' do
      expect(accounting_cost_series.meter).to eq original_meter
    end
  end

  context 'when using meter specific config' do
    let(:meter_definition)    { 123_456_789 }
    let(:meter)               { double('meter') }
    let(:sub_meters)          { Hash.new(nil) }

    before do
      allow(meter).to receive(:sub_meters).and_return(sub_meters)
      allow(meter).to receive(:original_meter).and_return(original_meter)
      allow(meter_collection).to receive(:meter?).and_return(meter)
    end

    context 'with a mains consumption sub meter' do
      # hash that returns true for each key, to fake there being a submeter
      let(:sub_meters) { [[:mains_consume, true]].to_h }

      it 'returns the sub meter' do
        expect(accounting_cost_series.meter).to eq original_meter
      end
    end

    context 'with no mains consumption sub meter' do
      it 'returns the requested meter' do
        expect(accounting_cost_series.meter).to eq meter
      end
    end
  end
end
