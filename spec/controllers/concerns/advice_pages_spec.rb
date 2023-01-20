require 'rails_helper'

describe AdvicePages, type: :controller do
  before do
    class TestAdvicePagesController < ApplicationController
      include AdvicePages
    end
  end

  after do
    Object.send :remove_const, :TestAdvicePagesController
  end

  let(:subject) { TestAdvicePagesController.new }

  describe '.variation_rating' do
    it 'shows 0% as 10.0' do
      expect(subject.variation_rating(0)).to eq(10.0)
    end
    it 'shows 10% as 8.0' do
      expect(subject.variation_rating(0.1)).to eq(8.0)
    end
    it 'shows -10% as 10.0' do
      expect(subject.variation_rating(-0.1)).to eq(8.0)
    end
    it 'shows 40% as 2.0' do
      expect(subject.variation_rating(0.4)).to eq(2.0)
    end
    it 'shows -40% as 2.0' do
      expect(subject.variation_rating(0.4)).to eq(2.0)
    end
    it 'shows 50% as 0.0' do
      expect(subject.variation_rating(0.5)).to eq(0.0)
    end
  end

  let(:meter_collection) { double(:meter_collection, electricity_meters: ['foo'], aggregated_electricity_meters: double(fuel_type: :electricity)) }
  let(:end_date) { Date.parse('20200101') }
  let(:usage) { 'usage' }
  let(:savings) { 'savings' }

  describe '.baseload_usage' do
    before do
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:annual_baseload_usage).and_return(usage)
    end
    it 'returns usage' do
      expect(subject.baseload_usage(meter_collection, end_date)).to eq(usage)
    end
  end

  describe '.benchmark_usage' do
    before do
      allow_any_instance_of(Baseload::BaseloadBenchmarkingService).to receive(:baseload_usage).and_return(usage)
    end
    it 'returns usage' do
      expect(subject.benchmark_usage(meter_collection, end_date)).to eq(usage)
    end
  end

  describe '.estimated_savings' do
    before do
      allow_any_instance_of(Baseload::BaseloadBenchmarkingService).to receive(:estimated_savings).and_return(savings)
    end
    it 'returns usage' do
      expect(subject.estimated_savings(meter_collection, end_date)).to eq(savings)
    end
  end

  describe '.annual_average_baseloads' do
    let(:start_date) { Date.parse('20190101')}
    let(:end_date) { Date.parse('20210101')}
    before do
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:annual_baseload_usage).and_return(usage)
    end
    it 'returns usage by years' do
      result = subject.annual_average_baseloads(meter_collection, start_date, end_date)
      expect(result.count).to eq(3)
      expect(result[0][:year]).to eq(2019)
      expect(result[0][:baseload_usage]).to eq(usage)
      expect(result[2][:year]).to eq(2021)
      expect(result[2][:baseload_usage]).to eq(usage)
    end
  end
end
