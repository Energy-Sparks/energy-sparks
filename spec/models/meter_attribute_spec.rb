require 'rails_helper'

describe MeterAttribute do
  describe 'validation' do
    let(:meter) { build(:electricity_meter) }

    it 'passes validation with blank input data' do
      described_class.create!(attribute_type: :function_switch, input_data: nil, meter: meter)
    end

    it 'passes validation with correct input data' do
      described_class.create!(attribute_type: :function_switch, input_data: 'heating_only', meter: meter)
    end

    it 'fails validation with incorrect input data' do
      expect do
        described_class.create!(attribute_type: :function_switch, input_data: 'not_a_value', meter: meter)
      end.to raise_error(ActiveRecord::RecordInvalid, /Invalid value/)
    end
  end

  describe '.to_analytics' do
    it 'aggregates attributes that have an aggregation key' do
      attribute_1 = described_class.new(attribute_type: :function_switch, input_data: 'heating_only')
      attribute_2 = described_class.new(attribute_type: :function_switch, input_data: 'kitchen_only')

      results = described_class.to_analytics([attribute_1, attribute_2])

      expect(results).to eq(
        {
          function: %i[heating_only kitchen_only]
        }
      )
    end

    it 'uses the key for normal attribute types' do
      attribute_1 = described_class.new(attribute_type: :targeting_and_tracking_profiles_maximum_retries,
                                        input_data: { number_of_retries: 1 })

      results = described_class.to_analytics([attribute_1])

      expect(results).to eq(
        {
          targeting_and_tracking_profiles_maximum_retries: { number_of_retries: 1 }
        }
      )
    end
  end
end
