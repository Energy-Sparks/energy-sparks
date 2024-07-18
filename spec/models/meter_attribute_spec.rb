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
          function: [:heating_only, :kitchen_only]
        }
      )
    end

    it 'uses the key for normal attribute types' do
      attribute_1 = described_class.new(attribute_type: :targeting_and_tracking_profiles_maximum_retries, input_data: { number_of_retries: 1 })

      results = described_class.to_analytics([attribute_1])

      expect(results).to eq(
        {
          targeting_and_tracking_profiles_maximum_retries: { number_of_retries: 1 }
        }
      )
    end
  end

  describe '.solar_pv' do
    let(:config) { { start_date: '2022-01-01', kwp: '10', end_date: '2023-01-01' } }
    let!(:solar_attribute) { create(:meter_attribute, attribute_type: :solar_pv, input_data: config)}
    let!(:other_attribute) { create(:meter_attribute, attribute_type: :targeting_and_tracking_profiles_maximum_retries, input_data: { number_of_retries: 1 })}
    let(:solar_panels)  { described_class.solar_pv }
    let(:panel)         { solar_panels.first }

    it 'returns expected data' do
      expect(solar_panels.size).to eq 1
      expect(panel.meter_attribute_id).to eq solar_attribute.id
      expect(panel.meter).to eq solar_attribute.meter
      expect(panel.school_id).to eq solar_attribute.meter.school.id
      expect(panel.school_name).to eq solar_attribute.meter.school_name
      expect(panel.start_date).to eq '2022-01-01'
      expect(panel.end_date).to eq '2023-01-01'
      expect(panel.kwp).to eq 10
    end
  end

  describe '.metered_solar' do
    let(:config) do
      {
        start_date: '2022-01-01',
        end_date: '2023-01-01',
        export_mpan: '1234',
        production_mpan: '1',
        production_mpan2: '2',
        production_mpan3: '3',
        production_mpan4: '4',
        production_mpan5: '5'
      }
    end
    let!(:solar_attribute) { create(:meter_attribute, attribute_type: :solar_pv_mpan_meter_mapping, input_data: config)}
    let!(:other_attribute) { create(:meter_attribute, attribute_type: :targeting_and_tracking_profiles_maximum_retries, input_data: { number_of_retries: 1 })}
    let(:solar_panels) { described_class.metered_solar }
    let(:mapping) { solar_panels.first }

    it 'returns expected data' do
      expect(solar_panels.size).to eq 1
      expect(mapping.meter_attribute_id).to eq solar_attribute.id
      expect(mapping.meter).to eq solar_attribute.meter
      expect(mapping.school_id).to eq solar_attribute.meter.school.id
      expect(mapping.school_name).to eq solar_attribute.meter.school_name
      expect(mapping.start_date).to eq '2022-01-01'
      expect(mapping.end_date).to eq '2023-01-01'
      expect(mapping.export_mpan).to eq('1234')
      expect(mapping.production_mpans).to eq(%w[1 2 3 4 5])
    end
  end
end
