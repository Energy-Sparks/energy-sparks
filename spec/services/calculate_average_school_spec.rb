# frozen_string_literal: true

# require 'dashboard'

require 'rails_helper'

describe CalculateAverageSchool, type: :service do
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

      # meter_collection = Amr::AnalyticsMeterCollectionFactory.new(school).unvalidated_data
      # AggregateDataService.new(meter_collection).validate_meter_data
      # AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters

      # data = described_class.new.calculate_school_averages(meter_collection, :electricity)
      # expect(data[:monthly_data][:weekend][4].uniq).to eq([1.0])
      # debugger
      unvalidated_data = Amr::AnalyticsMeterCollectionFactory.new(school).unvalidated_data

      s3 = Aws::S3::Client.new(stub_responses: true)
      s3.stub_responses(:list_objects_v2, { contents: [{ key: "unvalidated-data-#{school.slug}" }] })
      s3.stub_responses(:get_object, { body: EnergySparks::Gzip.gzip(YAML.dump(unvalidated_data)) })
      data = described_class.perform(s3:)
      # debugger
      expect(data.keys).to contain_exactly(:electricity, :gas)
      expect(data[:electricity].keys).to contain_exactly(:average, :benchmark, :exemplar)
      expect(data[:electricity][:average]).to eq(
        { primary: { samples: 1,
                     schoolday: { 4 => Array.new(48, 1.0), 5 => Array.new(48, 1.0) },
                     weekend: { 4 => Array.new(48, 1.0), 5 => Array.new(48, 1.0), 6 => Array.new(48, 1.0) } } }
      )
      expect(data[:gas]).to eq({ average: {}, benchmark: {}, exemplar: {} })
      # debugger
    end
  end
end
