# frozen_string_literal: true

# require 'dashboard'

require 'rails_helper'

describe CalculateAverageSchool, type: :service do
  let(:s3) do
    schools = [create(:school, number_of_pupils: 1), create(:school, number_of_pupils: 2)]
    unvalidated_data = schools.map do |school|
      create(:electricity_meter_with_validated_reading_dates,
             reading: school.number_of_pupils, end_date: Date.parse('30/07/2019'), school:)
      Amr::AnalyticsMeterCollectionFactory.new(school).unvalidated_data
    end
    keys = schools.map { |school| "unvalidated-data-#{school.slug}.yaml.gz" }
    s3 = Aws::S3::Client.new(stub_responses: true)
    s3.stub_responses(:list_objects_v2, { contents: keys.map { |key| { key: } } })
    unvalidated_data.each do |data|
      s3.stub_responses(:get_object, { body: EnergySparks::Gzip.gzip(data.to_yaml) })
    end
    s3
  end

  describe '#calculate_school_averages' do
    it 'calculates' do
      data = ClimateControl.modify(UNVALIDATED_SCHOOL_CACHE_BUCKET: 'bucket') { described_class.perform(s3:) }
      expect(data.keys).to contain_exactly(:electricity, :gas)
      expect(data[:electricity].keys).to contain_exactly(:average, :benchmark, :exemplar)
      expect(data[:electricity][:average]).to eq(
        { primary: { samples: 2,
                     schoolday: { 6 => Array.new(48, 1.0), 7 => Array.new(48, 1.0) },
                     weekend: { 6 => Array.new(48, 1.0), 7 => Array.new(48, 1.0) } } }
      )
      expect(data[:gas]).to eq({ average: {}, benchmark: {}, exemplar: {} })
    end
  end
end
