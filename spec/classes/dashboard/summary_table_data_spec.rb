require 'rails_helper'

describe Dashboard::SummaryTableData do

  subject { described_class.new(template_data) }

  # Format of the template_data from the analtyics ManagementSummaryTable should be:
  #
  #   {
  #     :electricity => {
  #       :start_date => '2016-10-01',
  #       :end_date => '2021-11-01',
  #       :year => {
  #         :kwh => 108_827.5394000001,
  #         :co2 => 21_333.057423499995,
  #         :£ => 16_324.130910000014,
  #         :savings_£ => 967.8809100000144,
  #         :percent_change => 0.11050720181070751
  #       },
  #       :workweek => {
  #         :recent => "",
  #         :kwh => 1205.2192,
  #         :co2 => 150.84771050000003,
  #         :£ => 180.78288,
  #         :savings_£ => "-",
  #         :percent_change => "-"
  #       }
  #     },
  #     :gas => {
  #       :start_date => '2021-04-13',
  #       :end_date => '2021-10-28',
  #       :year => {
  #         :available_from => "Data available from Apr 2022"
  #       },
  #       :workweek => {
  #         :recent => "No recent data",
  #         :kwh => 4930.7751,
  #         :co2 => 1035.462771,
  #         :£ => 147.923253,
  #         :savings_£ => "-",
  #         :percent_change => "-"
  #       }
  #     }
  #   }

  describe 'when time period valid' do
    let(:template_data) do
      { electricity: { year: { available_from: '' }, workweek: { recent: ''} } }
    end
    it 'shows annual valid' do
      expect(subject.by_fuel_type.first.valid).to be_truthy
      expect(subject.by_fuel_type.first.message).to be_nil
    end
    it 'shows workweek valid' do
      expect(subject.by_fuel_type.second.valid).to be_truthy
      expect(subject.by_fuel_type.second.message).to be_nil
    end
  end

  describe 'when one time period not valid' do
    let(:template_data) do
      { electricity: { year: { available_from: '' }, workweek: { recent: 'no recent data'} } }
    end
    it 'shows annual valid' do
      expect(subject.by_fuel_type.first.valid).to be_truthy
      expect(subject.by_fuel_type.first.message).to be_nil
    end
    it 'shows workweek not valid' do
      expect(subject.by_fuel_type.second.valid).to be_falsey
      expect(subject.by_fuel_type.second.message).to eq('no recent data')
    end
  end

  describe 'when 1 fuel type' do
    let(:template_data) do
      { electricity: { year: { kwh: 12.3, co2: 45.611, £: 6.6611, savings_£: 7.77 }, workweek: { kwh: 12.3, co2: 45.611, £: 6.6611, savings_£: 7.77 } } }
    end
    it 'gives 2 entries' do
      expect(subject.by_fuel_type.count).to eq(2)
    end
    it 'gives annual data' do
      expect(subject.by_fuel_type.first.period).to eq('Annual')
    end
    it 'gives last week data' do
      expect(subject.by_fuel_type.second.period).to eq('Last week')
    end
  end

  describe 'when 2 fuel types' do
    let(:template_data) do
      { electricity: { year: { }, workweek: {  } },  gas: { year: { }, workweek: {  } } }
    end
    it 'gives 4 entries' do
      expect(subject.by_fuel_type.count).to eq(4)
    end
    it 'gives annual data' do
      expect(subject.by_fuel_type[0].period).to eq('Annual')
      expect(subject.by_fuel_type[2].period).to eq('Annual')
    end
    it 'gives last week data' do
      expect(subject.by_fuel_type[1].period).to eq('Last week')
      expect(subject.by_fuel_type[3].period).to eq('Last week')
    end
  end

  describe 'annual usage, co2, costs, savings' do
    let(:template_data) do
      { electricity: { year: { kwh: 12.3, co2: 45.611, £: 6.6611, savings_£: 7.77 } } }
    end
    it 'shows usage' do
      expect(subject.by_fuel_type.first.usage).to eq('12.3')
    end
    it 'shows cost' do
      expect(subject.by_fuel_type.first.cost).to eq('&pound;6.66')
    end
    it 'shows co2' do
      expect(subject.by_fuel_type.first.co2).to eq('45.6')
    end
    it 'shows savings' do
      expect(subject.by_fuel_type.first.savings).to eq('&pound;7.77')
    end
  end

  describe 'percent change' do
    let(:template_data) do
      { electricity: { year: { :percent_change => 0.11050 }, workweek: { :percent_change => -0.0923132131 } } }
    end
    it 'formats percentage' do
      expect(subject.by_fuel_type.first.change).to eq('+11.1%')
      expect(subject.by_fuel_type.second.change).to eq('-9.23%')
    end
  end

  describe 'date_ranges' do
    context 'when no fuel type' do
      let(:template_data) do
        { }
      end
      it 'handles missing data' do
        expect(subject.date_ranges).to eq('')
      end
    end
    context 'when one fuel type' do
      let(:template_data) do
        { electricity: { start_date: '2020-01-09', end_date: '2021-11-23' } }
      end
      it 'formats dates' do
        expect(subject.date_ranges).to eq('Electricity data: Jan 2020 - Nov 2021.')
      end
    end
    context 'when multiple fuel types' do
      let(:template_data) do
        {
          electricity: { start_date: '2020-01-09', end_date: '2021-11-23' },
          gas: { start_date: '2018-06-09', end_date: '2019-07-23' }
        }
      end
      it 'formats dates' do
        expect(subject.date_ranges).to eq('Electricity data: Jan 2020 - Nov 2021. Gas data: Jun 2018 - Jul 2019.')
      end
    end
  end
end
