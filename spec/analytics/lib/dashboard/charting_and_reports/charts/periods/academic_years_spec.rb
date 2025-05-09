# frozen_string_literal: true

require 'rails_helper'

describe Periods::AcademicYears do
  def period(start_date, end_date, timescale_year)
    holidays = Holidays.new(
      HolidayData.new(
        [build(:holiday, name: 'Summer', start_date: Date.new(2023, 7, 21), end_date: Date.new(2023, 8, 31)),
         build(:holiday, name: 'Summer', start_date: Date.new(2022, 7, 22), end_date: Date.new(2022, 8, 31)),
         build(:holiday, name: 'Summer', start_date: Date.new(2021, 7, 23), end_date: Date.new(2021, 8, 31))]
      ), nil
    )
    meter_collection = build(:meter_collection, :with_aggregate_meter, fuel_type: :electricity, holidays:, start_date:, end_date:)
    chart_config = { timescale: { academicyear: timescale_year } }
    described_class.new(chart_config, meter_collection, start_date, end_date, chart_config[:timescale])
  end

  describe '#periods' do
    it 'gets part of the academic year' do
      expect(period(Date.new(2023, 1, 1), Date.new(2023, 12, 31), 0).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2023, 9, 1), end_date: Date.new(2023, 12, 31)))
    end

    it 'gets part of the previous academic year' do
      expect(period(Date.new(2023, 1, 1), Date.new(2023, 12, 31), -1).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 8, 31)))
    end

    it 'gets the previous academic year' do
      expect(period(Date.new(2022, 1, 1), Date.new(2023, 12, 31), -1).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2022, 9, 1), end_date: Date.new(2023, 8, 31)))
    end

    it 'works with no summer holidays defined' do
      expect(period(Date.new(2020, 1, 1), Date.new(2020, 12, 31), 0).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2020, 1, 1), end_date: Date.new(2020, 12, 31)))
    end
  end
end
