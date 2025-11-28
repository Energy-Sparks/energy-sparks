# frozen_string_literal: true

require 'rails_helper'
require 'analytics/lib/dashboard/alerts/shared_example_for_holiday_usage_alert'

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

  it_behaves_like 'a never relevant alert', :electricity
end
