require 'rails_helper'

describe MeterAttribute do
  describe 'validation' do
    let(:meter) { build(:electricity_meter) }

    it 'passes validation with blank input data' do
      MeterAttribute.create!(attribute_type: :function_switch, input_data: nil, meter: meter)
    end

    it 'passes validation with correct input data' do
      MeterAttribute.create!(attribute_type: :function_switch, input_data: 'heating_only', meter: meter)
    end

    it 'fails validation with incorrect input data' do
      expect do
        MeterAttribute.create!(attribute_type: :function_switch, input_data: 'not_a_value', meter: meter)
      end.to raise_error(ActiveRecord::RecordInvalid, /Invalid value/)
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
      attribute_1 = MeterAttribute.new(attribute_type: :targeting_and_tracking_profiles_maximum_retries, input_data: { number_of_retries: 1 })

      results = MeterAttribute.to_analytics([attribute_1])

      expect(results).to eq(
        {
          targeting_and_tracking_profiles_maximum_retries: { number_of_retries: 1 }
        }
      )
    end
  end

  describe '.solar_panels' do
    let(:config) { { start_date: "2022-01-01", kwp: "10", end_date: "2023-01-01", orientation: '0', tilt: '30', shading: '6', fit_£_per_kwh: '0.3' } }
    let!(:solar_attribute) { create(:meter_attribute, attribute_type: :solar_pv, input_data: config)}
    let!(:other_attribute) { create(:meter_attribute, attribute_type: :targeting_and_tracking_profiles_maximum_retries, input_data: { number_of_retries: 1 })}
    let(:solar_panels)  { MeterAttribute.solar_panels }
    let(:panel)         { solar_panels.first }

    it 'returns expected data' do
      expect(solar_panels.size).to eq 1
      expect(panel.meter_attribute_id).to eq solar_attribute.id
      expect(panel.meter).to eq solar_attribute.meter
      expect(panel.school_id).to eq solar_attribute.meter.school.id
      expect(panel.school_name).to eq solar_attribute.meter.school_name
      expect(panel.start_date).to eq '2022-01-01'
      expect(panel.end_date).to eq '2023-01-01'
      expect(panel.orientation).to eq '0'
      expect(panel.tilt).to eq '30'
      expect(panel.shading).to eq '6'
      expect(panel.fit_£_per_kwh).to eq '0.3'
    end
  end
end
