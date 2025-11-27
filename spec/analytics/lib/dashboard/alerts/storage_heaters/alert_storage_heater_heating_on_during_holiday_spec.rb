# frozen_string_literal: true

require 'rails_helper'

describe AlertStorageHeaterHeatingOnDuringHoliday do
  subject(:alert) do
    described_class.new(meter_collection)
  end

  context 'when school has storage heaters' do
    include_context 'with an aggregated meter with tariffs and school times' do
      let(:fuel_type) { :storage_heaters }
    end

    before do
      allow(meter_collection).to receive(:storage_heaters?).and_return(true) if fuel_type == :storage_heaters
    end

    it_behaves_like 'a holiday usage alert'
  end

  context 'when school does not have storage heaters' do
    it_behaves_like 'a never relevant alert' do
      let(:fuel_type) { :electricity }
    end
  end
end
