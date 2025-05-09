# frozen_string_literal: true

require 'spec_helper'

describe AlertGasHeatingHotWaterOnDuringHoliday do
  subject(:alert) do
    described_class.new(meter_collection)
  end

  context 'when a school has gas' do
    include_context 'with an aggregated meter with tariffs and school times' do
      let(:fuel_type) { :gas }
    end

    it_behaves_like 'a holiday usage alert'
  end

  context 'when a school has electricity only' do
    include_context 'with an aggregated meter with tariffs and school times' do
      let(:fuel_type) { :electricity }
    end
    include_context 'with today'

    let(:asof_date) { Date.new(2023, 12, 23) }

    it 'is never relevant' do
      expect(alert.relevance).to eq(:never_relevant)
    end
  end
end
