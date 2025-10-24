# frozen_string_literal: true

require 'rails_helper'

describe Usage::HolidayUsageCalculationService, type: :service do
  let(:fuel_type)        { :electricity }
  let(:meter_collection) { @acme_academy }
  let(:meter)            { meter_collection.aggregated_electricity_meters }
  let(:asof_date)        { Date.today }
  let(:service)          { described_class.new(meter, meter_collection.holidays, asof_date) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  context 'with electricity meters' do
    describe '#holiday_usage' do
      let(:academic_year) { nil }
      let(:school_period) { Holiday.new(holiday_type, name, start_date, end_date, academic_year) }
      let(:usage) { service.holiday_usage(school_period: school_period) }

      context 'with xmas 2021/2022' do
        let(:holiday_type)  { :xmas }
        let(:name)          { 'Xmas 2021/2022' }
        let(:start_date)    { Date.new(2021, 12, 18) }
        # last day of xmas holiday
        let(:end_date)      { Date.new(2022, 0o1, 3) }

        it 'calculates the expected usage' do
          expect(usage.kwh).to be_within(0.1).of(10_425.6)
          expect(usage.co2).to be_within(0.1).of(1794.7996)
          expect(usage.£).to be_within(0.1).of(1262.19)
        end
      end

      context 'with xmas 2020/2021' do
        let(:holiday_type)  { :xmas }
        let(:name)          { 'Xmas 2020/2021' }
        let(:start_date)    { Date.new(2020, 12, 19) }
        # last day of xmas holiday
        let(:end_date)      { Date.new(2021, 1, 3) }

        it 'calculates the expected usage' do
          expect(usage.kwh).to be_within(0.1).of(11_728.89)
          expect(usage.co2).to be_within(0.1).of(2068.9643)
          expect(usage.£).to be_within(0.1).of(1437.97)
        end
      end

      context 'with autumn half term 2021' do
        let(:holiday_type)  { :autumn_half_term }
        let(:name)          { 'Autumn half term' }
        let(:start_date)    { Date.new(2021, 10, 23) }
        let(:end_date)      { Date.new(2021, 10, 31) }

        it 'calculates the expected usage' do
          expect(usage.kwh).to be_within(0.1).of(7801.6)
          expect(usage.co2).to be_within(0.1).of(979.229)
          expect(usage.£).to be_within(0.1).of(911.40)
        end
      end

      context 'when the period is outside meter range' do
        let(:holiday_type)  { :xmas }
        let(:name)          { 'Christmas 2023' }
        let(:start_date)    { Date.new(2023, 12, 20) }
        let(:end_date)      { Date.new(2024, 1, 0o2) }

        it 'returns nil' do
          expect(usage).to eq nil
        end
      end

      context 'when period is in the middle of a holiday' do
        let(:holiday_type)  { :xmas }
        let(:name)          { 'Xmas 2021/2022' }
        let(:start_date)    { Date.new(2021, 12, 18) }
        # last day of xmas holiday
        let(:end_date)      { Date.new(2022, 0o1, 3) }
        let(:asof_date)     { Date.new(2021, 12, 25) }

        it 'returns partial usage' do
          # less than usage for full holiday
          expect(usage.kwh).to be <= 10_425.6
        end
      end
    end

    describe '#holiday_usage_comparison' do
      let(:academic_year) { nil }
      let(:school_period) { Holiday.new(holiday_type, name, start_date, end_date, academic_year) }
      let(:comparison) { service.holiday_usage_comparison(school_period: school_period) }

      context 'with xmas 2021/2022' do
        let(:holiday_type)  { :xmas }
        let(:name)          { 'Xmas' }
        let(:start_date)    { Date.new(2021, 12, 18) }
        let(:end_date)      { Date.new(2022, 0o1, 3) }

        it 'produces the right comparison' do
          xmas_2021_usage = comparison.usage
          expect(xmas_2021_usage.kwh).to be_within(0.1).of(10_425.6)
          expect(xmas_2021_usage.co2).to be_within(0.1).of(1794.7996)
          expect(xmas_2021_usage.£).to be_within(0.1).of(1262.19)

          expect(comparison.previous_holiday).not_to be_nil

          xmas_2020_usage = comparison.previous_holiday_usage
          expect(xmas_2020_usage.kwh).to be_within(0.1).of(11_728.89)
          expect(xmas_2020_usage.co2).to be_within(0.1).of(2068.9643)
          expect(xmas_2020_usage.£).to be_within(0.1).of(1437.97)
        end
      end

      context 'when the period is outside the meter range' do
        let(:holiday_type)  { :easter }
        let(:name)          { 'Easter 2019' }
        let(:start_date)    { Date.new(2019, 4, 13) }
        let(:end_date)      { Date.new(2019, 4, 28) }

        it 'returns nil for previous year' do
          expect(comparison.usage).not_to be_nil
          expect(comparison.previous_holiday_usage).to be_nil
        end
      end
    end

    describe '#holidays_usage_comparison' do
      let(:academic_year) { nil }
      let(:school_period1) do
        Holiday.new(:xmas, 'Xmas 2021/2022', Date.new(2021, 12, 18), Date.new(2022, 0o1, 3), academic_year)
      end
      let(:school_period2) do
        Holiday.new(:autumn_half_term, 'Autum half term', Date.new(2021, 10, 23), Date.new(2021, 10, 31), academic_year)
      end
      let(:comparison) { service.holidays_usage_comparison(school_periods: [school_period1, school_period2]) }

      it 'calculates all comparisons' do
        expect(comparison[school_period1]).not_to be_nil
        expect(comparison[school_period2]).not_to be_nil
      end
    end

    describe '#school_holiday_calendar_comparison' do
      context 'with Easter 2022' do
        let(:asof_date) { Date.new(2022, 4, 1) }
        let(:holiday_comparison) { service.school_holiday_calendar_comparison }

        it 'finds all the holidays' do
          holiday_types = holiday_comparison.keys.map(&:type)
          expect(holiday_types).to match_array(%i[autumn_half_term xmas spring_half_term easter
                                                  summer_half_term summer])
        end

        it 'calculates usage for all holidays' do
          holiday_comparison.each_value do |usage|
            expect(usage.usage).not_to be_nil
          end
        end

        it 'has Easter as latest' do
          latest_holiday = holiday_comparison.keys.max { |a, b| b.start_date <=> a.start_date }
          expect(latest_holiday.type).to eq :easter
        end
      end

      context 'with Summer 2022' do
        # last meter date
        let(:asof_date)        { Date.new(2022, 7, 13) }
        let(:service)          { described_class.new(meter, meter_collection.holidays, asof_date) }
        let(:holiday_comparison) { service.school_holiday_calendar_comparison }

        it 'finds all the holidays' do
          holiday_types = holiday_comparison.keys.map(&:type)
          expect(holiday_types).to match_array(%i[autumn_half_term xmas spring_half_term easter
                                                  summer_half_term summer])
        end

        it 'calculates usage for all holidays' do
          holiday_comparison.each_value do |usage|
            expect(usage.usage).not_to be_nil
          end
        end

        it 'has summer' do
          latest_holiday = holiday_comparison.keys.max { |a, b| b.start_date <=> a.start_date }
          expect(latest_holiday.type).to eq :summer
        end
      end

      context 'with missing future holiday' do
        # last meter date
        let(:asof_date) { Date.new(2023, 9, 1) }
        let(:service) do
          holidays = meter_collection.holidays
          # remove summer holiday for 2024, to simulate school calendar not being
          # kept up to date
          holidays.holidays.delete_if { |h| h.type == :summer && h.academic_year == (2023..2024) }
          described_class.new(meter, holidays, asof_date)
        end
        let(:holiday_comparison) { service.school_holiday_calendar_comparison }

        it 'finds all the holidays' do
          holiday_types = holiday_comparison.keys.map(&:type)
          expect(holiday_types).to match_array(%i[autumn_half_term xmas spring_half_term easter
                                                  summer_half_term summer])
        end

        it 'calculates usage for all holidays' do
          holiday_comparison.each_value do |usage|
            expect(usage.usage).not_to be_nil
          end
        end

        it 'has summer' do
          latest_holiday = holiday_comparison.keys.max_by(&:start_date)
          expect(latest_holiday.type).to eq :summer
        end
      end
    end
  end
end
