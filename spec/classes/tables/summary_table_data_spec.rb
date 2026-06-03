require 'rails_helper'

describe Tables::SummaryTableData do
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
  #         :gbp => 16_324.130910000014,
  #         :savings_gbp => 967.8809100000144,
  #         :percent_change => 0.11050720181070751
  #       },
  #       :last_month => {
  #         :recent => "",
  #         :kwh => 1205.2192,
  #         :co2 => 150.84771050000003,
  #         :gbp => 180.78288,
  #         :savings_gbp => "-",
  #         :percent_change => "-"
  #       }
  #       :workweek => {
  #         :recent => "",
  #         :kwh => 1205.2192,
  #         :co2 => 150.84771050000003,
  #         :gbp => 180.78288,
  #         :savings_gbp => "-",
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
  #         :gbp => 147.923253,
  #         :savings_gbp => "-",
  #         :percent_change => "-"
  #       }
  #     }
  #   }
  #
  #
  #  Recent improvements
  #
  #     :gas => {
  #       :start_date => '2021-04-13',
  #       :end_date => '2021-10-28',
  #       :year => {
  #         :available_from => '2021-10-28'
  #       },
  #       :workweek => {
  #         :recent => false,
  #         :kwh => 4930.7751,
  #         :co2 => 1035.462771,
  #         :gbp => 147.923253,
  #         :savings_gbp => "-",
  #         :percent_change => "-"
  #       }
  #     }

  describe 'handles no data' do
    let(:template_data) do
      {}
    end

    it 'returns empty list' do
      expect(subject.by_fuel_type).to eq([])
    end

    it 'handles date_ranges' do
      expect(subject.date_ranges).to eq('')
    end
  end

  describe 'when period does not have data' do
    let(:template_data) do
      { electricity: { year: { available_from: 'Data available from Feb 2022' } } }
    end

    it 'shows status and message' do
      expect(subject.by_fuel_type.second.has_data).to be_falsey
      expect(subject.by_fuel_type.second.message).to eq('Data available from Feb 2022')
    end
  end

  describe 'when year period does not have data - new style' do
    let(:available_date) { Time.zone.today.next_year }
    let(:template_data) do
      { electricity: { year: { available_from: available_date.iso8601 } } }
    end

    it 'shows status and message' do
      expect(subject.by_fuel_type.second.has_data).to be_falsey
      expect(subject.by_fuel_type.second.message).to eq("Data available from #{available_date.strftime('%b %Y')}")
    end
  end

  describe 'when week period does not have data - new style' do
    let(:available_date) { 7.days.from_now }
    let(:template_data) do
      { electricity: { year: { available_from: available_date.iso8601 } } }
    end

    it 'shows status and message' do
      expect(subject.by_fuel_type.second.has_data).to be_falsey
      expect(subject.by_fuel_type.second.message).to eq("Data available from #{available_date.strftime('%a %d %b %Y')}")
    end
  end

  describe 'when period has data' do
    let(:template_data) do
      { electricity: { year: { kwh: '123' }, workweek: { co2: '456' }, last_month: { co2: '456' } } }
    end

    it 'shows status' do
      subject.by_fuel_type.each do |fuel_type|
        expect(fuel_type.has_data).to be_truthy
      end
    end
  end

  describe 'when data is not recent' do
    let(:template_data) do
      { electricity: { year: { kwh: '123', recent: 'no recent data' } } }
    end

    it 'shows status, message and class' do
      expect(subject.by_fuel_type.second.has_data).to be false
      expect(subject.by_fuel_type.second.message).to eq('no recent data')
      expect(subject.by_fuel_type.second.message_class).to eq('old-data')
    end
  end

  describe 'when data is not recent - new style' do
    let(:template_data) do
      { electricity: { year: { kwh: '123', recent: false } } }
    end

    it 'shows status, message and class' do
      expect(subject.by_fuel_type.second.has_data).to be false
      expect(subject.by_fuel_type.second.message).to eq('no recent data')
      expect(subject.by_fuel_type.second.message_class).to eq('old-data')
    end
  end

  describe 'when data is recent - new style' do
    let(:template_data) do
      { electricity: { year: { kwh: '123', recent: true } } }
    end

    it 'shows status, message and class' do
      expect(subject.by_fuel_type.second.has_data).to be true
      expect(subject.by_fuel_type.second.message_class).not_to eq('old-data')
    end
  end

  describe 'when 1 fuel type' do
    let(:template_data) do
      { electricity: { year: { kwh: 12.3, co2: 45.611, gbp: 6.6611, savings_gbp: 7.77 }, workweek: { kwh: 12.3, co2: 45.611, gbp: 6.6611, savings_gbp: 7.77 } } }
    end

    it 'gives 2 entries' do
      expect(subject.by_fuel_type.count).to eq(2)
    end

    it 'gives annual data' do
      expect(subject.by_fuel_type.second.period).to eq('Last year')
      expect(subject.by_fuel_type.second.period_key).to eq(:year)
    end

    it 'gives last week data' do
      expect(subject.by_fuel_type.first.period).to eq('Last week')
      expect(subject.by_fuel_type.first.period_key).to eq(:workweek)
    end
  end

  describe 'when 2 fuel types' do
    let(:template_data) do
      { electricity: { year: {}, workweek: {} }, gas: { year: {}, workweek: {} } }
    end

    it 'gives 4 entries' do
      expect(subject.by_fuel_type.count).to eq(4)
    end

    it 'gives annual data' do
      expect(subject.by_fuel_type[1].period).to eq('Last year')
      expect(subject.by_fuel_type[3].period).to eq('Last year')
    end

    it 'gives last week data' do
      expect(subject.by_fuel_type[0].period).to eq('Last week')
      expect(subject.by_fuel_type[2].period).to eq('Last week')
    end
  end

  describe 'annual usage, co2, costs, savings' do
    let(:template_data) do
      { electricity: { year: { kwh: 12.3, co2: 45.611, gbp: 6.6611, savings_gbp: 7.77 } } }
    end

    it 'shows usage' do
      expect(subject.by_fuel_type.second.usage).to eq('12.3')
    end

    it 'shows cost' do
      expect(subject.by_fuel_type.second.cost).to eq('&pound;6.66')
    end

    it 'shows co2' do
      expect(subject.by_fuel_type.second.co2).to eq('45.6')
    end

    it 'shows savings' do
      expect(subject.by_fuel_type.second.savings).to eq('&pound;7.77')
    end

    context 'when one value is missing' do
      let(:template_data) do
        { electricity: { year: { kwh: 12.3, co2: nil, gbp: 6.6611, savings_gbp: 7.77 } } }
      end

      it 'returns empty string' do
        expect(subject.by_fuel_type.first.co2).to eq('')
      end
    end
  end

  describe 'percent change' do
    let(:template_data) do
      { electricity: { year: { :percent_change => 0.11050 }, workweek: { :percent_change => -0.0923132131 } } }
    end

    it 'formats percentage' do
      expect(subject.by_fuel_type.first.change).to eq('-9.2%')
      expect(subject.by_fuel_type.second.change).to eq('+11%')
    end
  end

  describe 'percent change not calculable' do
    let(:template_data) do
      { electricity: { year: { :percent_change => '-' } } }
    end

    it 'formats percentage' do
      expect(subject.by_fuel_type.second.change).to eq('-')
    end
  end

  describe 'date_ranges' do
    context 'when no fuel type' do
      let(:template_data) do
        {}
      end

      it 'handles missing data' do
        expect(subject.date_ranges).to eq('')
      end
    end

    context 'when missing date field' do
      let(:template_data) do
        { electricity: { start_date: '', end_date: '2021-11-23' } }
      end

      it 'handles the error and does its best' do
        expect(subject.date_ranges).to eq('Electricity data:  - 23 Nov 2021.')
      end
    end

    context 'when one fuel type' do
      let(:template_data) do
        { electricity: { start_date: '2020-01-09', end_date: '2021-11-23' } }
      end

      it 'formats dates' do
        expect(subject.date_ranges).to eq('Electricity data: 9 Jan 2020 - 23 Nov 2021.')
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
        expect(subject.date_ranges).to eq('Electricity data: 9 Jan 2020 - 23 Nov 2021. Gas data: 9 Jun 2018 - 23 Jul 2019.')
      end
    end
  end
end
