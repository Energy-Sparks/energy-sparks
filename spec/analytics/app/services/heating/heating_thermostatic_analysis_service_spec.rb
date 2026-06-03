# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe Heating::HeatingThermostaticAnalysisService do
  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
    @beta_academy = load_unvalidated_meter_collection(school: 'beta-academy')
  end

  describe '#enough_data?' do
    let(:service) { described_class.new(meter_collection: @acme_academy, fuel_type: :gas) }

    it 'determines if there is enough data' do
      expect(service.enough_data?).to eq(true)
    end
  end

  describe '#create_model' do
    let(:model) { service.create_model }

    context 'with gas' do
      let(:service) { described_class.new(meter_collection: @acme_academy, fuel_type: :gas) }

      it 'creates a model for results of a heating thermostatic analysis for gas' do
        expect(model.r2).to be_within(0.005).of(0.81)
        expect(model.insulation_hotwater_heat_loss_estimate_kwh).to be_within(0.01).of(298_689.32)
        expect(model.insulation_hotwater_heat_loss_estimate_£).to be_within(0.01).of(8960.67)
        expect(model.average_heating_school_day_a).to be_within(0.01).of(4654.57)
        expect(model.average_heating_school_day_b).to be_within(0.01).of(-236.24)
        expect(model.average_outside_temperature_high).to eq(12.0)
        expect(model.average_outside_temperature_low).to eq(4.0)
        expect(model.predicted_kwh_for_high_average_outside_temperature).to be_within(0.01).of(1819.60)
        expect(model.predicted_kwh_for_low_average_outside_temperature).to be_within(0.01).of(3709.58)
      end
    end

    context 'with storage heaters' do
      let(:service) { described_class.new(meter_collection: @beta_academy, fuel_type: :storage_heater) }

      it 'creates a model for results of a heating thermostatic analysis' do
        expect(model.r2).to be_within(0.005).of(0.48)
        expect(model.insulation_hotwater_heat_loss_estimate_kwh).to be_within(0.01).of(38_990.95)
        expect(model.insulation_hotwater_heat_loss_estimate_£).to be_within(0.01).of(7054.12)
        expect(model.average_heating_school_day_a).to be_within(0.01).of(755.12)
        expect(model.average_heating_school_day_b).to be_within(0.01).of(-27.33)
        expect(model.average_outside_temperature_high).to eq(12.0)
        expect(model.average_outside_temperature_low).to eq(4.0)
        expect(model.predicted_kwh_for_high_average_outside_temperature).to be_within(0.01).of(427.07)
        expect(model.predicted_kwh_for_low_average_outside_temperature).to be_within(0.01).of(645.77)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
