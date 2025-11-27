# frozen_string_literal: true

require 'rails_helper'

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
    it_behaves_like 'a never relevant alert' do
      let(:fuel_type) { :electricity }
    end
  end
end
