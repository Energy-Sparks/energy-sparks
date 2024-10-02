# frozen_string_literal: true

require 'spec_helper'

describe AlertElectricityUsageDuringCurrentHoliday do
  subject(:alert) do
    described_class.new(meter_collection)
  end

  context 'when a school has electricity' do
    include_context 'with an aggregated meter with tariffs and school times'
    it_behaves_like 'a holiday usage alert'
  end

  context 'when a school has gas only' do
    include_context 'with an aggregated meter with tariffs and school times' do
      let(:fuel_type) { :gas }
    end

    let(:asof_date) { Date.new(2023, 12, 23) }
    let(:today)     { asof_date.iso8601 }

    # The alert checks the current date, but has option to override via
    # an environment variable. So by default set it as if we're running
    # on the asof_date
    around do |example|
      ClimateControl.modify ENERGYSPARKSTODAY: today do
        example.run
      end
    end

    it 'is never relevant' do
      expect(alert.relevance).to eq(:never_relevant)
    end
  end
end
