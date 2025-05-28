# frozen_string_literal: true

require 'rails_helper'

describe Baseload::BaseloadBenchmarkingService, type: :service do
  let(:asof_date)      { Date.new(2022, 2, 1) }
  let(:service)        { described_class.new(@acme_academy, asof_date) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#average_baseload_kw' do
    it 'calculates baseload for a benchmark school' do
      # numbers taken from running the AlertElectricityBaseloadVersusBenchmark alert
      expect(service.average_baseload_kw(compare: :benchmark_school)).to be_within(0.01).of(18.76)
    end

    it 'calculated baseload for an exemplar school' do
      # numbers taken from running the AlertElectricityBaseloadVersusBenchmark alert
      expect(service.average_baseload_kw(compare: :exemplar_school)).to be_within(0.01).of(11.26)
    end
  end

  describe '#baseload_usage' do
    it 'calculates usage for a benchmark school' do
      # numbers taken from running the AlertElectricityBaseloadVersusBenchmark alert
      usage = service.baseload_usage(compare: :benchmark_school)
      expect(usage.kwh).to be_within(0.01).of(164_328.84)
      expect(usage.£).to be_within(0.01).of(19_232.10)
      expect(usage.co2).to be_within(0.01).of(27_455.47)
    end

    it 'calculates usage for an exemplar school' do
      # numbers taken from running the AlertElectricityBaseloadVersusBenchmark alert
      usage = service.baseload_usage(compare: :exemplar_school)
      expect(usage.kwh).to be_within(0.01).of(98_597.3)
      expect(usage.£).to be_within(0.01).of(11_539.26)
      expect(usage.co2).to be_within(0.01).of(16_473.28)
    end
  end

  describe '#estimated_savings' do
    it 'calculates savings vs benchmark school' do
      # numbers taken from running the AlertElectricityBaseloadVersusBenchmark alert
      usage = service.estimated_savings(versus: :benchmark_school)
      expect(usage.kwh).to be_within(0.01).of(48_672.96)
      expect(usage.£).to be_within(0.01).of(5696.40)
      expect(usage.co2).to be_within(0.01).of(8132.10)
    end

    it 'calculates savings vs exemplar school' do
      # numbers taken from running the AlertElectricityBaseloadVersusBenchmark alert
      usage = service.estimated_savings(versus: :exemplar_school)
      expect(usage.kwh).to be_within(0.01).of(114_404.5)
      expect(usage.£).to be_within(0.01).of(13_389.24)
      expect(usage.co2).to be_within(0.01).of(19_114.29)
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
