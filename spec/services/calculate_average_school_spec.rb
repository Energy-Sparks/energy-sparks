# frozen_string_literal: true

# require 'dashboard'

require 'rails_helper'

describe CalculateAverageSchool, type: :service do
  let(:school) do
    school = create(:school)
    create(:electricity_meter_with_reading, readings: Array.new(48, 1), reading_count: 50, school:)
    school
  end

  describe '#calculate_school_averages' do
    it 'calculates' do
      unvalidated_data = Amr::AnalyticsMeterCollectionFactory.new(school).unvalidated_data

      s3 = Aws::S3::Client.new(stub_responses: true)
      s3.stub_responses(:list_objects_v2, { contents: [{ key: "unvalidated-data-#{school.slug}" }] })
      s3.stub_responses(:get_object, { body: EnergySparks::Gzip.gzip(YAML.dump(unvalidated_data)) })
      data = ClimateControl.modify UNVALIDATED_SCHOOL_CACHE_BUCKET: 'bucket' do
        described_class.perform(s3:)
      end
      expect(data.keys).to contain_exactly(:electricity, :gas)
      expect(data[:electricity].keys).to contain_exactly(:average, :benchmark, :exemplar)
      expect(data[:electricity][:average]).to eq(
        { primary: { samples: 1,
                     schoolday: { 4 => Array.new(48, 1.0), 5 => Array.new(48, 1.0) },
                     weekend: { 4 => Array.new(48, 1.0), 5 => Array.new(48, 1.0), 6 => Array.new(48, 1.0) } } }
      )
      expect(data[:gas]).to eq({ average: {}, benchmark: {}, exemplar: {} })
    end
  end
end
