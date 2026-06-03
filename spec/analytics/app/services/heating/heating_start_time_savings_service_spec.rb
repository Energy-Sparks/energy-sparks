# frozen_string_literal: true

require 'rails_helper'

describe Heating::HeatingStartTimeSavingsService, type: :service do
  let(:asof_date)      { Date.new(2022, 2, 1) }
  let(:service)        { described_class.new(@acme_academy, asof_date) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#percentage_of_annual_gas' do
    it 'returns the expected data' do
      expect(service.percentage_of_annual_gas).to be_within(0.01).of(0.02)
    end
  end

  describe '#estimated_savings', :aggregate_failures do
    it 'returns the expected data' do
      estimated_savings = service.estimated_savings
      expect(estimated_savings.kwh).to be_within(0.01).of(18_217.64)
      expect(estimated_savings.£).to be_within(0.01).of(546.52)
      expect(estimated_savings.co2).to be_within(0.01).of(3325.26)
    end
  end

  describe '#enough_data?' do
    context 'when theres is a years worth' do
      it 'returns true' do
        expect(service.enough_data?).to be true
      end
    end

    context 'when theres is limited data' do
      # acme academy has gas data starting in 2018-09-01
      let(:asof_date) { Date.new(2018, 10, 2) }

      it 'returns false' do
        expect(service.enough_data?).to be false
      end
    end
  end
end
