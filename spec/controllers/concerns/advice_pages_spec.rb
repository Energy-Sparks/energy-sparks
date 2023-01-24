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

  describe '.calculate_rating_from_range' do
    let(:good) {0.0}
    let(:bad)  {0.5}
    it 'shows 0% as 10.0' do
      expect(subject.calculate_rating_from_range(good, bad, 0)).to eq(10.0)
    end
    it 'shows 10% as 8.0' do
      expect(subject.calculate_rating_from_range(good, bad, 0.1)).to eq(8.0)
    end
    it 'shows -10% as 8.0' do
      expect(subject.calculate_rating_from_range(good, bad, -0.1.abs)).to eq(8.0)
    end
    it 'shows 40% as 2.0' do
      expect(subject.calculate_rating_from_range(good, bad, 0.4)).to eq(2.0)
    end
    it 'shows -40% as 2.0' do
      expect(subject.calculate_rating_from_range(good, bad, -0.4)).to eq(2.0)
    end
    it 'shows 50% as 0.0' do
      expect(subject.calculate_rating_from_range(good, bad, 0.5)).to eq(0.0)
    end
  end

  let(:electricity_meters) { ['electricity-meter'] }
  let(:meter_collection) { double(:meter_collection, electricity_meters: electricity_meters, aggregated_electricity_meters: double(fuel_type: :electricity)) }
  let(:end_date) { Date.parse('20200101') }
  let(:usage) { CombinedUsageMetric.new(£: 0, kwh: 0, co2: 0) }
  let(:average_baseload_kw) { 2.1 }
  let(:savings) { double(£: 1, co2: 2) }

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
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:average_baseload_kw).and_return(average_baseload_kw)
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

  let(:breakdown) { double(meters: []) }
  let(:average_baseload_kw) { 123.0 }

  describe '.build_meter_breakdown_total' do
    let(:start_date) { Date.parse('20190101')}
    let(:end_date) { Date.parse('20210101')}
    before do
      allow_any_instance_of(Baseload::BaseloadMeterBreakdownService).to receive(:calculate_breakdown).and_return(breakdown)
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:annual_baseload_usage).and_return(usage)
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:average_baseload_kw).and_return(average_baseload_kw)
    end
    it 'returns usage by years' do
      result = subject.build_meter_breakdown_total(meter_collection, end_date)
      expect(result.to_h.keys).to match_array([:baseload_kw, :baseload_change_kw, :baseload_cost_£, :percentage_baseload, :baseload_previous_year_kw])
      expect(result.baseload_previous_year_kw).to eq(123.0)
    end
  end

  let(:seasonal_variation) { double(winter_kw: 1, summer_kw: 2, percentage: 3) }

  describe '.seasonal_variation' do
    before do
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:seasonal_variation).and_return(seasonal_variation)
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:estimated_costs).and_return(savings)
    end
    it 'returns variation' do
      result = subject.seasonal_variation(meter_collection, end_date)
      expect(result.to_h.keys).to match_array([:estimated_saving_co2, :estimated_saving_£, :percentage, :summer_kw, :variation_rating, :winter_kw])
    end
  end

  describe '.seasonal_variation_by_meter' do
    let(:electricity_meter_1) { double(mpan_mprn: 'meter1', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity) }
    let(:electricity_meter_2) { double(mpan_mprn: 'meter2', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity) }
    let(:electricity_meters) { [electricity_meter_1, electricity_meter_2] }

    before do
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:seasonal_variation).and_return(seasonal_variation)
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:estimated_costs).and_return(savings)
    end
    it 'returns variation' do
      result = subject.seasonal_variation_by_meter(meter_collection)
      expect(result.keys).to match_array(['meter1', 'meter2'])
      expect(result['meter1'].to_h.keys).to match_array([:estimated_saving_co2, :estimated_saving_£, :percentage, :summer_kw, :variation_rating, :winter_kw])
    end
  end

  let(:intraweek_variation) { double(max_day_kw: 1, min_day_kw: 2, percent_intraday_variation: 3) }

  describe '.intraweek_variation' do
    before do
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:intraweek_variation).and_return(intraweek_variation)
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:estimated_costs).and_return(savings)
    end
    it 'returns variation' do
      result = subject.intraweek_variation(meter_collection, end_date)
      expect(result.to_h.keys).to match_array([:estimated_saving_co2, :estimated_saving_£, :max_day_kw, :min_day_kw, :percent_intraday_variation, :variation_rating])
    end
  end

  describe '.intraweek_variation_by_meter' do
    let(:electricity_meter_1) { double(mpan_mprn: 'meter1', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity) }
    let(:electricity_meter_2) { double(mpan_mprn: 'meter2', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity) }
    let(:electricity_meters) { [electricity_meter_1, electricity_meter_2] }
    before do
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:intraweek_variation).and_return(intraweek_variation)
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:estimated_costs).and_return(savings)
    end
    it 'returns variation' do
      result = subject.intraweek_variation_by_meter(meter_collection)
      expect(result.keys).to match_array(['meter1', 'meter2'])
      expect(result['meter1'].to_h.keys).to match_array([:estimated_saving_co2, :estimated_saving_£, :max_day_kw, :min_day_kw, :percent_intraday_variation, :variation_rating])
    end
  end
end
