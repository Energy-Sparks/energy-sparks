require 'rails_helper'

describe MeterAttribute do

  describe 'validation' do

    let(:meter) { build(:electricity_meter) }

    it 'validates input data' do
      expect {
        MeterAttribute.create!(attribute_type: :function_switch, input_data: 'not_a_value', meter: meter)
      }.to raise_error(ActiveRecord::RecordInvalid, /Invalid value/)
    end
  end

  describe '.to_analytics' do

    it 'aggregates attributes that have an aggregation key' do
      attribute_1 = MeterAttribute.new(attribute_type: :function_switch, input_data: 'heating_only')
      attribute_2 = MeterAttribute.new(attribute_type: :function_switch, input_data: 'kitchen_only')

      results = MeterAttribute.to_analytics([attribute_1, attribute_2])

      expect(results).to eq(
        {
          function: [:heating_only, :kitchen_only]
        }
      )
    end

    it 'uses the key for normal attribute types' do
      attribute_1 = MeterAttribute.new(attribute_type: :tariff, input_data: {type: 'economy_7'})

      results = MeterAttribute.to_analytics([attribute_1])

      expect(results).to eq(
        {
          tariff: {type: :economy_7}
        }
      )
    end

  end
end
