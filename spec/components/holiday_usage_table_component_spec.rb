require 'rails_helper'

RSpec.describe HolidayUsageTableComponent, type: :component do
  let(:final_holiday_end) { Date.new(2023, 10, 22) }
  let(:data_end_date)     { final_holiday_end }

  let(:analysis_dates) do
    OpenStruct.new(
      start_date: Date.new(2022, 1, 1),
      end_date: data_end_date
    )
  end

  let(:holiday_1) { build(:school_date_period, type: :spring_half_term, start_date: Date.new(2023, 2, 18), end_date: Date.new(2023, 2, 21)) }
  let(:holiday_2) { build(:school_date_period, type: :easter, start_date: Date.new(2023, 4, 29), end_date: Date.new(2023, 5, 1)) }
  let(:holiday_3) { build(:school_date_period, type: :summer, start_date: Date.new(2023, 6, 30), end_date: Date.new(2023, 8, 13)) }
  let(:holiday_4) { build(:school_date_period, type: :autumn_half_term, start_date: Date.new(2023, 10, 7), end_date: final_holiday_end)}

  let(:holiday_usage) do
    previous_holiday_1 = build(:school_date_period, start_date: Date.new(2022, 2, 19), end_date: Date.new(2022, 2, 22))
    previous_holiday_2 = build(:school_date_period, start_date: Date.new(2022, 4, 2), end_date: Date.new(2022, 4, 18))
    previous_holiday_3 = build(:school_date_period, start_date: Date.new(2022, 7, 1), end_date: Date.new(2022, 8, 14))
    previous_holiday_4 = build(:school_date_period, start_date: Date.new(2022, 10, 8), end_date: Date.new(2022, 10, 23))

    {
      # no data for holidays
      holiday_1 => OpenStruct.new(
        usage: nil,
        previous_holiday_usage: nil,
        previous_holiday: previous_holiday_1
      ),
      # full data for holiday but not previous
      holiday_2 => OpenStruct.new(
        usage: CombinedUsageMetric.new(kwh: 10.0, £: 10.0, co2: 10.0),
        previous_holiday_usage: nil,
        previous_holiday: previous_holiday_2
      ),
      # full data for holiday and previous holiday
      holiday_3 => OpenStruct.new(
        usage: CombinedUsageMetric.new(kwh: 20.0, £: 20.0, co2: 20.0),
        previous_holiday_usage: CombinedUsageMetric.new(kwh: 40.0, £: 40.0, co2: 40.0),
        previous_holiday: previous_holiday_3
      ),
      # data for both holidays, tests adjust date ranges/times
      holiday_4 => OpenStruct.new(
        usage: CombinedUsageMetric.new(kwh: 20.0, £: 20.0, co2: 20.0),
        previous_holiday_usage: CombinedUsageMetric.new(kwh: 40.0, £: 40.0, co2: 40.0),
        previous_holiday: previous_holiday_4
      )
    }
  end

  let(:filter_empty_holidays) { false }

  let(:params) do
    {
      holiday_usage: holiday_usage,
      analysis_dates: analysis_dates,
      filter_empty_holidays: filter_empty_holidays
    }
  end

  subject(:component) { described_class.new(**params) }

  let(:html) do
    render_inline(component)
  end

  describe '.render?' do
    it 'returns true with data' do
      expect(component.render?).to be true
    end

    context 'when there is no data' do
      let(:holiday_usage) { {} }

      it 'doesnt render' do
        expect(component.render?).to be false
      end
    end
  end

  describe '.school_periods' do
    it 'returns in date order' do
      expect(component.school_periods).to eq([holiday_1, holiday_2, holiday_3, holiday_4])
    end

    context 'when filtering empty periods' do
      let(:filter_empty_holidays) { true }

      it 'returns only periods with usage in both holidays' do
        expect(component.school_periods).to eq([holiday_2, holiday_3, holiday_4])
      end
    end
  end

  describe '.can_compare_holiday_usage?' do
    context 'with no data for holidays' do
      it 'returns false' do
        expect(component.can_compare_holiday_usage?(holiday_1)).to be false
      end
    end

    context 'with no data for previous holiday' do
      it 'returns false' do
        expect(component.can_compare_holiday_usage?(holiday_2)).to be false
      end
    end

    context 'with data for both holidays' do
      it 'returns true' do
        expect(component.can_compare_holiday_usage?(holiday_3)).to be true
      end
    end

    context 'when we are past current holiday' do
      it 'returns true' do
        expect(component.can_compare_holiday_usage?(holiday_4)).to be true
      end
    end

    context 'when we have partial data for current holiday' do
      let(:data_end_date) { final_holiday_end - 2.days }

      it 'returns false' do
        expect(component.can_compare_holiday_usage?(holiday_4)).to be false
      end
    end
  end

  describe '.within_school_period?' do
    context 'when we are past holiday' do
      it 'returns true' do
        expect(component.within_school_period?(holiday_1)).to be false
      end
    end

    context 'when we have partial data for current holiday' do
      let(:data_end_date) { final_holiday_end - 2.days }

      it 'returns false' do
        expect(component.within_school_period?(holiday_4)).to be true
      end
    end
  end

  describe '.average_daily_usage' do
    it 'returns expected result' do
      usage = CombinedUsageMetric.new(kwh: 100.0, £: 100.0, co2: 100.0)
      expect(component.average_daily_usage(usage, holiday_3)).to eq(usage.kwh / holiday_3.days)
    end
  end

  describe '.current_holiday_row' do
    it 'yields expected values' do
      component.current_holiday_row(holiday_4) do |label, holiday, usage, average_daily_usage|
        expect(label).to eq('')
        expect(holiday).to eq(holiday_4)
        expect(usage).to eq(holiday_usage[holiday_4].usage)
        expect(average_daily_usage).to eq(holiday_usage[holiday_4].usage.kwh / holiday_4.days)
      end
    end
  end

  describe '.previous_holiday_row' do
    it 'yields expected values' do
      component.previous_holiday_row(holiday_4) do |label, holiday, usage, average_daily_usage|
        expect(label).to eq(I18nHelper.holiday(:autumn_half_term))
        expect(holiday).to eq(holiday_usage[holiday_4].previous_holiday)
        expect(usage).to eq(holiday_usage[holiday_4].previous_holiday_usage)
        expect(average_daily_usage).to eq(holiday_usage[holiday_4].previous_holiday_usage.kwh / holiday_usage[holiday_4].previous_holiday.days)
      end
    end
  end

  describe '.comparison_row' do
    context 'when comparison can be made' do
      it 'yields expected values' do
        component.comparison_row(holiday_3) do |label, holiday, usage, previous_holiday, previous_holiday_usage|
          expect(label).to eq('')
          expect(holiday).to eq(holiday_3)
          expect(usage).to eq(holiday_usage[holiday_3].usage)
          expect(previous_holiday_usage).to eq(holiday_usage[holiday_3].previous_holiday_usage)
          expect(previous_holiday).to eq(holiday_usage[holiday_3].previous_holiday)
        end
      end
    end

    context 'when comparison cant be made as only partial data for holiday' do
      let(:data_end_date) { final_holiday_end - 2.days }

      it 'returns nil' do
        expect(component.comparison_row(holiday_4)).to be false
      end
    end
  end

  context 'when rendering' do
    it 'adds class to table' do
      expect(html).to have_css('.holiday-usage-table')
    end

    it 'adds a default id' do
      expect(html).to have_css('#holiday-usage-table')
    end

    it 'generates expected number of rows' do
      # two rows per holiday, plus 2 comparison rows for holiday_3 and holiday_4
      expect(html).to have_css('table.holiday-usage-table tbody tr', count: 10)
    end

    context 'with an id' do
      let(:params) do
        {
          holiday_usage: holiday_usage,
          analysis_dates: analysis_dates,
          id: 'custom-id'
        }
      end

      it 'uses the id' do
        expect(html).to have_css('#custom-id')
      end
    end
  end
end
