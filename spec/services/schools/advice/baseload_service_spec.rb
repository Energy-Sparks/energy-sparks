require 'rails_helper'

RSpec.describe Schools::Advice::BaseloadService, type: :service do

  let(:school) { create(:school) }
  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true)}

  let(:electricity_meters) { ['electricity-meter'] }
  let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter')}

  let(:meter_collection) { double(:meter_collection, electricity_meters: electricity_meters, aggregated_electricity_meters: electricity_aggregate_meter) }

  let(:amr_data)    { double('amr-data') }
  let(:start_date)  { Date.parse('20190101')}
  let(:end_date)    { Date.parse('20210101')}

  let(:usage) { CombinedUsageMetric.new(£: 0, kwh: 0, co2: 0) }
  let(:average_baseload_kw) { 2.1 }
  let(:savings) { double(£: 1, co2: 2) }

  let(:service)   { Schools::Advice::BaseloadService.new(school, meter_collection) }

  before do
    school.configuration.update!(fuel_configuration: fuel_configuration)
    allow(amr_data).to receive(:start_date).and_return(start_date)
    allow(amr_data).to receive(:end_date).and_return(end_date)
    allow(electricity_aggregate_meter).to receive(:fuel_type).and_return(:electricity)
    allow(electricity_aggregate_meter).to receive(:amr_data).and_return(amr_data)
    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)
  end

  describe '#has_electricity?' do
    it 'checks the fuel types'
  end

  describe '#multiple_meters?' do
    it 'checks the meter count'
  end

  describe '#average_baseload_kw' do
    it 'returns the baseload'
  end

  describe '#previous_year_average_baseload_kw' do
    it 'returns the baseload'

  end

  describe '#annual_baseload_usage' do
    before do
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:annual_baseload_usage).and_return(usage)
    end
    it 'returns usage' do
      expect(service.annual_baseload_usage).to eq(usage)
    end
  end

  describe '#average_baseload_kw_benchmark' do
    it 'returns the baseload vs benchmark'
  end

  describe '#baseload_usage_benchmark' do
    before do
      allow_any_instance_of(Baseload::BaseloadBenchmarkingService).to receive(:baseload_usage).and_return(usage)
    end
    it 'returns usage' do
      expect(service.baseload_usage_benchmark).to eq(usage)
    end
  end

  describe '#baseload_usage_benchmark' do
    it 'returns the usage'
  end

  describe '#estimated_savings' do
    before do
      allow_any_instance_of(Baseload::BaseloadBenchmarkingService).to receive(:estimated_savings).and_return(savings)
    end
    it 'returns usage' do
      expect(service.estimated_savings).to eq(savings)
    end
  end

  describe '#annual_average_baseloads' do
    let(:start_date) { Date.parse('20190101')}
    let(:end_date) { Date.parse('20210101')}
    before do
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:annual_baseload_usage).and_return(usage)
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:average_baseload_kw).and_return(average_baseload_kw)
    end
    it 'returns usage by years' do
      result = service.annual_average_baseloads
      expect(result.count).to eq(3)
      expect(result[0][:year]).to eq(2019)
      expect(result[0][:baseload_usage]).to eq(usage)
      expect(result[2][:year]).to eq(2021)
      expect(result[2][:baseload_usage]).to eq(usage)
    end
  end

  describe '#baseload_meter_breakdown' do
    it 'returns the meter breakdown'
  end

  describe '#meter_breakdown_table_total' do
    it 'returns the total'
  end

  describe '#seasonal_variation' do
    let(:seasonal_variation) { double(winter_kw: 1, summer_kw: 2, percentage: 3) }
    before do
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:seasonal_variation).and_return(seasonal_variation)
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:estimated_costs).and_return(savings)
    end
    it 'returns variation' do
      result = service.seasonal_variation
      expect(result.to_h.keys).to match_array([:estimated_saving_co2, :estimated_saving_£, :percentage, :summer_kw, :variation_rating, :winter_kw])
    end

  end

  describe '#seasonal_variation_by_meter' do
    let(:seasonal_variation) { double(winter_kw: 1, summer_kw: 2, percentage: 3) }
    let(:electricity_meter_1) { double(mpan_mprn: 'meter1', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity) }
    let(:electricity_meter_2) { double(mpan_mprn: 'meter2', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity) }
    let(:electricity_meters) { [electricity_meter_1, electricity_meter_2] }

    before do
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:seasonal_variation).and_return(seasonal_variation)
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:estimated_costs).and_return(savings)
    end
    it 'returns variation' do
      result = service.seasonal_variation_by_meter
      expect(result.keys).to match_array(['meter1', 'meter2'])
      expect(result['meter1'].to_h.keys).to match_array([:estimated_saving_co2, :estimated_saving_£, :percentage, :summer_kw, :variation_rating, :winter_kw])
    end
  end

  describe '#intraweek_variation' do
    let(:intraweek_variation) { double(max_day_kw: 1, min_day_kw: 2, percent_intraday_variation: 3) }
    before do
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:intraweek_variation).and_return(intraweek_variation)
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:estimated_costs).and_return(savings)
    end
    it 'returns variation' do
      result = service.intraweek_variation
      expect(result.to_h.keys).to match_array([:estimated_saving_co2, :estimated_saving_£, :max_day_kw, :min_day_kw, :percent_intraday_variation, :variation_rating])
    end

  end

  describe '#intraweek_variation_by_meter' do
    let(:intraweek_variation) { double(max_day_kw: 1, min_day_kw: 2, percent_intraday_variation: 3) }
    let(:electricity_meter_1) { double(mpan_mprn: 'meter1', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity) }
    let(:electricity_meter_2) { double(mpan_mprn: 'meter2', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity) }
    let(:electricity_meters) { [electricity_meter_1, electricity_meter_2] }
    before do
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:intraweek_variation).and_return(intraweek_variation)
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:estimated_costs).and_return(savings)
    end
    it 'returns variation' do
      result = service.intraweek_variation_by_meter
      expect(result.keys).to match_array(['meter1', 'meter2'])
      expect(result['meter1'].to_h.keys).to match_array([:estimated_saving_co2, :estimated_saving_£, :max_day_kw, :min_day_kw, :percent_intraday_variation, :variation_rating])
    end

  end

  describe '#calculate_rating_from_range' do
    let(:good) {0.0}
    let(:bad)  {0.5}
    it 'shows 0% as 10.0' do
      expect(service.calculate_rating_from_range(good, bad, 0)).to eq(10.0)
    end
    it 'shows 10% as 8.0' do
      expect(service.calculate_rating_from_range(good, bad, 0.1)).to eq(8.0)
    end
    it 'shows -10% as 8.0' do
      expect(service.calculate_rating_from_range(good, bad, -0.1.abs)).to eq(8.0)
    end
    it 'shows 40% as 2.0' do
      expect(service.calculate_rating_from_range(good, bad, 0.4)).to eq(2.0)
    end
    it 'shows -40% as 2.0' do
      expect(service.calculate_rating_from_range(good, bad, -0.4)).to eq(2.0)
    end
    it 'shows 50% as 0.0' do
      expect(service.calculate_rating_from_range(good, bad, 0.5)).to eq(0.0)
    end
  end
end
