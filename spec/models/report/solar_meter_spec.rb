# frozen_string_literal: true

require 'rails_helper'

describe Report::SolarMeter do
  let(:meter) { create(:gas_meter, school: create(:school, :with_school_group)) }
  let!(:mapping_attribute) do
    create(:meter_attribute, attribute_type: :solar_pv_mpan_meter_mapping,
                             meter:,
                             input_data: { start_date: '2022-01-01',
                                           end_date: '2023-01-01',
                                           export_mpan: '1234',
                                           production_mpan: '1',
                                           production_mpan2: '2',
                                           production_mpan3: '3',
                                           production_mpan4: '4',
                                           production_mpan5: '5' })
  end
  let!(:pv_attribute) do
    create(:solar_pv_attribute, meter:)
  end

  before do
    create(:meter_attribute, meter:, attribute_type: :solar_pv_override, input_data: {})
    create(:meter_attribute, meter:, attribute_type: :modelled_solar_pv_generation,
                             input_data: {})
    create(:meter_attribute, meter:, attribute_type: :targeting_and_tracking_profiles_maximum_retries,
                             input_data: { number_of_retries: 1 })
  end

  describe '.modelled' do
    let(:meters) { described_class.modelled }

    it 'returns the expected data' do
      expect(meters.size).to eq 1
      expect(meters.first).to have_attributes(id: meter.id, solar_attribute_data: pv_attribute.input_data)
    end
  end

  describe '.modelled_school_ids' do
    let!(:mapping_attribute) { nil }

    it 'returns the expected data' do
      expect(described_class.modelled_school_ids).to eq([meter.school_id])
    end
  end

  describe '.metered' do
    let(:meters) { described_class.metered }

    it 'returns the expected data' do
      expect(meters.size).to eq 1
      expect(meters.first).to have_attributes(id: meter.id,
                                              solar_attribute_data: mapping_attribute.input_data,
                                              has_solar_pv_override_attribute: true,
                                              has_solar_pv_attribute: true,
                                              has_modelled_solar_pv_generation_attribute: true)
    end

    describe '.metered_school_ids' do
      it 'has the school id' do
        expect(described_class.metered_school_ids).to eq([meter.school_id])
      end
    end
  end
end
