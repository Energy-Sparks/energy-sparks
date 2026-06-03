# frozen_string_literal: true

require 'rails_helper'

describe Periods::FixedAcademicYear do
  def period(start_date, end_date, timescale_year)
    meter_collection = build(:meter_collection, :with_aggregate_meter, fuel_type: :electricity, start_date:, end_date:)
    chart_config = { timescale: { fixed_academic_year: timescale_year } }
    described_class.new(chart_config, meter_collection, start_date, end_date, chart_config[:timescale])
  end

  describe '#periods' do
    it 'gets part of the academic year' do
      expect(period(Date.new(2023, 1, 1), Date.new(2023, 12, 31), 0).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2023, 9, 1), end_date: Date.new(2023, 12, 31)))
      expect(period(Date.new(2023, 1, 1), Date.new(2023, 8, 31), 0).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 8, 31)))
      expect(period(Date.new(2022, 9, 1), Date.new(2022, 12, 31), 0).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2022, 9, 1), end_date: Date.new(2022, 12, 31)))
    end

    it 'gets part of the previous academic year' do
      expect(period(Date.new(2023, 1, 1), Date.new(2023, 12, 31), -1).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2023, 1, 1), end_date: Date.new(2023, 8, 31)))
    end

    it 'gets the previous academic year' do
      expect(period(Date.new(2022, 1, 1), Date.new(2023, 12, 31), -1).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2022, 9, 1), end_date: Date.new(2023, 8, 31)))
    end

    it 'handles the boundary correctly' do
      expect(period(Date.new(2023, 9, 1), Date.new(2023, 12, 31), -1).periods).to eq([nil])
      expect(period(Date.new(2023, 8, 31), Date.new(2023, 12, 31), -1).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2023, 8, 31), end_date: Date.new(2023, 8, 31)))
      expect(period(Date.new(2023, 10, 31), Date.new(2023, 12, 31), 0).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2023, 10, 31), end_date: Date.new(2023, 12, 31)))
      expect(period(Date.new(2023, 7, 31), Date.new(2023, 8, 30), 0).periods).to \
        contain_exactly(have_attributes(start_date: Date.new(2023, 7, 31), end_date: Date.new(2023, 8, 30)))
    end
  end
end
