require 'rails_helper'

RSpec.describe Schools::Advice::BaseloadService, type: :service do
  let(:school) { create(:school) }
  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true) }

  let(:electricity_meters) { ['electricity-meter'] }
  let(:electricity_aggregate_meter) { double('electricity-aggregated-meter', aggregate_meter?: true) }

  let(:meter_collection) { double(:meter_collection, electricity_meters: electricity_meters, aggregated_electricity_meters: electricity_aggregate_meter) }

  let(:amr_data)    { double('amr-data') }
  let(:start_date)  { Date.parse('20190101') }
  let(:end_date)    { Date.parse('20210101') }

  let(:usage) { CombinedUsageMetric.new(£: 0, kwh: 0, co2: 0) }
  let(:average_baseload_kw) { 2.1 }
  let(:exemplar_average_baseload_kw) { 1.9 }
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
    it 'checks the fuel types' do
      expect(service.has_electricity?).to be true
    end
  end

  describe '#multiple_electricity_meters?' do
    it 'checks the meter count' do
      expect(service.multiple_electricity_meters?).to be false
    end
  end

  describe '#average_baseload_kw' do
    before do
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:average_baseload_kw).and_return(average_baseload_kw)
    end

    it 'returns the baseload' do
      expect(service.average_baseload_kw).to eq average_baseload_kw
    end
  end

  describe '#previous_period_average_baseload_kw' do
    before do
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:average_baseload_kw).and_return(average_baseload_kw)
    end

    it 'returns the baseload' do
      expect(service.previous_period_average_baseload_kw).to eq average_baseload_kw
    end
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
    before do
      allow_any_instance_of(Baseload::BaseloadBenchmarkingService).to receive(:average_baseload_kw).and_return(average_baseload_kw)
    end

    it 'returns the baseload vs benchmark' do
      expect(service.average_baseload_kw_benchmark).to eq(average_baseload_kw)
    end
  end

  describe '#benchmark_baseload' do
    before do
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:average_baseload_kw).and_return(usage)
      allow_any_instance_of(Baseload::BaseloadBenchmarkingService).to receive(:average_baseload_kw).with(compare: :benchmark_school).and_return(average_baseload_kw)
      allow_any_instance_of(Baseload::BaseloadBenchmarkingService).to receive(:average_baseload_kw).with(compare: :exemplar_school).and_return(exemplar_average_baseload_kw)
    end

    it 'returns a comparison' do
      comparison = service.benchmark_baseload
      expect(comparison.school_value).to eq usage
      expect(comparison.benchmark_value).to eq average_baseload_kw
      expect(comparison.exemplar_value).to eq exemplar_average_baseload_kw
      expect(comparison.unit).to eq :kw
    end
  end

  describe '#baseload_usage_benchmark' do
    before do
      allow_any_instance_of(Baseload::BaseloadBenchmarkingService).to receive(:baseload_usage).and_return(usage)
    end

    it 'returns usage' do
      expect(service.baseload_usage_benchmark).to eq(usage)
    end
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
    let(:start_date) { Date.parse('20190101') }
    let(:end_date) { Date.parse('20210101') }

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
    let(:meter_1)   { 1_591_058_886_735 }
    let(:data)      { { meter_1 => { kw: 0, percent: 0, £: 0 } } }
    let(:breakdown) { Baseload::MeterBaseloadBreakdown.new(meter_breakdown: data) }
    let!(:db_meter) { create(:electricity_meter, school: school, mpan_mprn: 1_591_058_886_735) }

    before do
      allow_any_instance_of(Baseload::BaseloadMeterBreakdownService).to receive(:calculate_breakdown).and_return(breakdown)
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:annual_baseload_usage).and_return(usage)
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:average_baseload_kw).and_return(average_baseload_kw)
      allow(meter_collection).to receive(:meter?).and_return(double('meter', fuel_type: :electricity, amr_data: amr_data))
    end

    it 'returns usage by years' do
      result = service.baseload_meter_breakdown
      expect(result.keys).to match_array([meter_1])
      expect(result[meter_1].to_h.keys).to match_array(%i[baseload_kw baseload_change_kw baseload_cost_£ percentage_baseload baseload_previous_year_kw meter])
      expect(result[meter_1].meter).to eq(db_meter)
      expect(result[meter_1].baseload_previous_year_kw).to eq(average_baseload_kw)
    end
  end

  describe '#meter_breakdown_table_total' do
    before do
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:average_baseload_kw).and_return(average_baseload_kw)
      allow_any_instance_of(Baseload::BaseloadCalculationService).to receive(:annual_baseload_usage).and_return(usage)
    end

    it 'returns the total' do
      result = service.meter_breakdown_table_total
      expect(result.baseload_kw).to eq average_baseload_kw
      expect(result.baseload_cost_£).to eq usage.£
      expect(result.percentage_baseload).to eq 1.0
      expect(result.baseload_previous_year_kw).to eq average_baseload_kw
      expect(result.baseload_change_kw).to eq 0
    end
  end

  describe '#seasonal_variation' do
    let(:seasonal_variation) { double(winter_kw: 1, summer_kw: 2, percentage: 3.0) }

    before do
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:seasonal_variation).and_return(seasonal_variation)
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:estimated_costs).and_return(savings)
    end

    it 'returns variation' do
      result = service.seasonal_variation
      expect(result.to_h.keys).to match_array(%i[estimated_saving_co2 estimated_saving_£ percentage summer_kw variation_rating winter_kw meter enough_data?])
    end
  end

  describe '#seasonal_variation_by_meter' do
    let(:seasonal_variation) { double(winter_kw: 1, summer_kw: 2, percentage: 3.0) }
    let(:electricity_meter_1) { double(mpan_mprn: 'meter1', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity, aggregate_meter?: false) }
    let(:electricity_meter_2) { double(mpan_mprn: 'meter2', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity, aggregate_meter?: false) }
    let(:electricity_meters) { [electricity_meter_1, electricity_meter_2] }
    let(:enough_data) { true }
    let(:data_available_from) { nil }

    before do
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:seasonal_variation).and_return(seasonal_variation)
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:enough_data?).and_return(enough_data)
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:data_available_from).and_return(data_available_from)
      allow_any_instance_of(Baseload::SeasonalBaseloadService).to receive(:estimated_costs).and_return(savings)
    end

    it 'returns variation' do
      result = service.seasonal_variation_by_meter
      expect(result.keys).to match_array(%w[meter1 meter2])
      expect(result['meter1'].to_h.keys).to match_array(%i[estimated_saving_co2 estimated_saving_£ percentage summer_kw variation_rating winter_kw meter enough_data?])
    end

    context 'and theres not enough data' do
      let(:enough_data) { false }
      let(:data_available_from) { Date.today + 10 }

      it 'returns a limited variation' do
        result = service.seasonal_variation_by_meter
        expect(result.keys).to match_array(%w[meter1 meter2])
        expect(result['meter1'].to_h.keys).to match_array(%i[meter enough_data? data_available_from])
      end
    end
  end

  describe '#intraweek_variation' do
    let(:intraweek_variation) { double(max_day_kw: 1, min_day_kw: 2, percent_intraday_variation: 3, max_day: 0, min_day: 1) }

    before do
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:intraweek_variation).and_return(intraweek_variation)
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:estimated_costs).and_return(savings)
    end

    it 'returns variation' do
      result = service.intraweek_variation
      expect(result.to_h.keys).to match_array(%i[estimated_saving_co2 estimated_saving_£ max_day_kw min_day_kw percent_intraday_variation variation_rating meter enough_data? min_day max_day])
    end
  end

  describe '#intraweek_variation_by_meter' do
    let(:intraweek_variation) { double(max_day_kw: 1, min_day_kw: 2, percent_intraday_variation: 3, max_day: 0, min_day: 1) }
    let(:electricity_meter_1) { double(mpan_mprn: 'meter1', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity, aggregate_meter?: false) }
    let(:electricity_meter_2) { double(mpan_mprn: 'meter2', amr_data: double(end_date: Date.parse('20200101')), fuel_type: :electricity, aggregate_meter?: false) }
    let(:electricity_meters) { [electricity_meter_1, electricity_meter_2] }
    let(:enough_data) { true }
    let(:data_available_from) { nil }

    before do
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:intraweek_variation).and_return(intraweek_variation)
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:enough_data?).and_return(enough_data)
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:data_available_from).and_return(data_available_from)
      allow_any_instance_of(Baseload::IntraweekBaseloadService).to receive(:estimated_costs).and_return(savings)
    end

    it 'returns variation' do
      result = service.intraweek_variation_by_meter
      expect(result.keys).to match_array(%w[meter1 meter2])
      expect(result['meter1'].to_h.keys).to match_array(%i[estimated_saving_co2 estimated_saving_£ max_day_kw min_day_kw percent_intraday_variation variation_rating meter enough_data? min_day max_day])
    end

    context 'and theres not enough data' do
      let(:enough_data) { false }
      let(:data_available_from) { Date.today + 10 }

      it 'returns a limited variation' do
        result = service.intraweek_variation_by_meter
        expect(result.keys).to match_array(%w[meter1 meter2])
        expect(result['meter1'].to_h.keys).to match_array(%i[meter enough_data? data_available_from])
      end
    end
  end

  describe '#date_ranges_by_meter' do
    let(:electricity_meter_1) { double(mpan_mprn: 'meter1', amr_data: double(start_date: Date.parse('20190101'), end_date: Date.parse('20200101'))) }
    let(:electricity_meter_2) { double(mpan_mprn: 'meter2', amr_data: double(start_date: Date.parse('20180101'), end_date: Date.parse('20210101'))) }
    let(:electricity_meters) { [electricity_meter_1, electricity_meter_2] }

    it 'returns date ranges' do
      result = service.date_ranges_by_meter
      expect(result.keys).to match_array(%w[meter1 meter2])
      expect(result['meter1'][:start_date]).to eq(Date.parse('20190101'))
      expect(result['meter1'][:end_date]).to eq(Date.parse('20200101'))
    end
  end

  describe '#calculate_rating_from_range' do
    let(:good) { 0.0 }
    let(:bad)  { 0.5 }

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
