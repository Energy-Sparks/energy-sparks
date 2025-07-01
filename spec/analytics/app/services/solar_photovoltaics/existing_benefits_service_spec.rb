# frozen_string_literal: true

require 'rails_helper'

describe SolarPhotovoltaics::ExistingBenefitsService, type: :service do
  let(:service) do
    described_class.new(meter_collection: load_unvalidated_meter_collection(school: 'acme-academy-with-solar'))
  end

  describe '#enough_data?' do
    it 'returns true if one years worth of data is available' do
      expect(service.enough_data?).to eq(true)
    end
  end

  describe '#create_model' do
    let(:benefits) { service.create_model }

    it 'calculates the existing benefits for a school with solar pv', :aggregate_failures do
      expect(benefits.annual_saving_from_solar_pv_percent).to be_within(0.01).of(0.177)
      expect(benefits.annual_electricity_including_onsite_solar_pv_consumption_kwh).to be_within(0.01).of(42_599.63)
      expect(benefits.annual_carbon_saving_percent).to be_within(0.01).of(0.30)
      expect(benefits.saving_£current).to be_within(0.01).of(3030.16)
      expect(benefits.export_£).to be_within(0.01).of(210.70)
      expect(benefits.annual_co2_saving_kg).to be_within(0.01).of(1935.26)

      # summary table of electricity usage for the last year
      expect(benefits.annual_solar_pv_kwh).to be_within(0.01).of(12_959.86)
      expect(benefits.annual_exported_solar_pv_kwh).to be_within(0.01).of(4213.93)
      expect(benefits.annual_solar_pv_consumed_onsite_kwh).to be_within(0.01).of(7221.04)
      expect(benefits.annual_consumed_from_national_grid_kwh).to be_within(0.01).of(35_378.59)
    end
  end
end
