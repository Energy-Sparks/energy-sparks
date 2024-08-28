# frozen_string_literal: true

# require 'dashboard'

require 'rails_helper'

describe AverageCalculator, type: :service do
  let(:school) do
    # reading_start_date { 1.year.ago }
    # reading_end_date { Time.zone.today }
    school = create(:school)

    create(:electricity_meter_with_reading, readings: Array.new(48, 1), reading_count: 50, school:)

    # create(:electricity_meter_with_reading,
    #        school:,
    # start_date: evaluator.reading_start_date,
    # end_date: evaluator.reading_end_date,
    # reading: evaluator.reading)

    school
  end

  describe '#calculate_school_averages' do
    it 'runs' do
      # debugger

      meter_collection = Amr::AnalyticsMeterCollectionFactory.new(school).unvalidated
      AggregateDataService.new(meter_collection).validate_meter_data
      AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters

      data = described_class.new.calculate_school_averages(meter_collection, :electricity)
      expect(data[:monthly_data][:weekend][4].uniq).to eq([1.0])
      debugger
    end
  end
end
