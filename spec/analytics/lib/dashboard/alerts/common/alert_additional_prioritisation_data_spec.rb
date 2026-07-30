# frozen_string_literal: true

require 'rails_helper'

describe AlertAdditionalPrioritisationData do
  let(:fuel_type) { :electricity }

  let(:amr_start_date)  { Date.new(2021, 12, 31) }
  let(:amr_end_date)    { Date.new(2022, 12, 31) }
  let(:amr_data) { build(:amr_data, :with_date_range, start_date: amr_start_date, end_date: amr_end_date) }

  # Meter to use as the aggregate
  let(:meter) { build(:meter, :with_flat_rate_tariffs, type: fuel_type, amr_data: amr_data, tariff_start_date: amr_start_date, tariff_end_date: amr_end_date) }

  let(:meter_collection) { build(:meter_collection) }

  let(:asof_date)        { Date.new(2022, 12, 31) }
  let(:alert)            { AlertAdditionalPrioritisationData.new(meter_collection) }

  before do
    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(meter)
    allow(meter_collection).to receive(:aggregated_heat_meters).and_return(meter)
  end

  describe '#analyse' do
    before do
      alert.analyse(asof_date)
    end

    context 'when producing variables for reporting' do
      subject(:variables) { alert.variables_for_reporting }

      it 'produces simple variables used in comparison reports' do
        expect(variables[:activation_date]).to eq meter_collection.school.activation_date
        expect(variables[:pupils]).to eq meter_collection.school.number_of_pupils
        expect(variables[:floor_area]).to eq meter_collection.school.floor_area
        expect(variables[:school_type_name]).to eq(I18n.t('analytics.school_types')[meter_collection.school.school_type])
      end
    end
  end
end
