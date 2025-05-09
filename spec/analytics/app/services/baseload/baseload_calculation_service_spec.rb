# frozen_string_literal: true

require 'rails_helper'

describe Baseload::BaseloadCalculationService, type: :service do
  let(:asof_date)      { Date.new(2022, 2, 1) }
  let(:meter)          { @acme_academy.aggregated_electricity_meters }
  let(:service)        { described_class.new(meter, asof_date) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#average_baseload_kw' do
    it 'calculates baseload for a year' do
      # numbers taken from running the AlertElectricityBaseloadVersusBenchmark alert
      expect(service.average_baseload_kw).to be_within(0.01).of(24.32)
    end

    it 'calculates baseload for a week' do
      # numbers taken from running the AlertChangeInElectricityBaseloadShortTerm alert
      expect(service.average_baseload_kw(period: :week)).to be_within(0.005).of(25.62)
    end
  end

  describe '#saving_through_1_kw_reduction_in_baseload' do
    it 'calculates saving through 1 kw reduction in_baseload' do
      saving = service.saving_through_1_kw_reduction_in_baseload
      expect(saving.kwh).to eq(Baseload::BaseloadCalculationService::KWH_SAVING_FOR_EACH_ONE_KW_REDUCTION_IN_BASELOAD)
      expect(saving.£).to be_within(0.01).of(1025.22)
      expect(saving.co2).to be_within(0.01).of(1463.58)
    end
  end

  describe '#annual_baseload_usage' do
    it 'calculates the values' do
      usage = service.annual_baseload_usage

      # numbers taken from running the AlertElectricityBaseloadVersusBenchmark alert
      expect(usage.kwh).to be_within(0.01).of(213_001.8)
      expect(usage.co2).to be_within(0.01).of(35_587.57)
      expect(usage.£).to be_within(0.01).of(24_928.51)
      expect(usage.percent).to be_nil
    end

    it 'includes percentage if needed' do
      usage = service.annual_baseload_usage(include_percentage: true)
      expect(usage.percent).to be_within(0.01).of(0.47)
    end
  end

  describe '#enough_data?' do
    context 'when theres is a years worth' do
      it 'returns true' do
        expect(service.enough_data?).to be true
        expect(service.data_available_from).to be nil
      end
    end

    context 'when theres is limited data' do
      # acme academy has data starting in 2019-01-13
      let(:asof_date) { Date.new(2019, 1, 21) }

      it 'returns false' do
        expect(service.enough_data?).to be false
        expect(service.data_available_from).not_to be nil
      end
    end
  end
end
