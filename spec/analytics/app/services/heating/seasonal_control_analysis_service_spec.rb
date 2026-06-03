# frozen_string_literal: true

require 'rails_helper'

describe Heating::SeasonalControlAnalysisService, :aggregate_failures do
  let(:service) { described_class.new(meter_collection: @acme_academy, fuel_type: :gas) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
    @beta_academy = load_unvalidated_meter_collection(school: 'beta-academy')
  end

  describe '#enough_data?' do
    context 'when theres is a years worth' do
      it 'returns true' do
        expect(service.enough_data?).to be true
        expect(service.data_available_from).to be_nil
      end
    end

    context 'when theres is limited data' do
      # acme academy has gas data starting in 2018-09-01
      let(:asof_date) { Date.new(2019, 6, 13) }

      before do
        allow_any_instance_of(AMRData).to receive(:end_date).and_return(asof_date)
      end

      it 'returns false' do
        expect(service.enough_data?).to be false
        expect(service.data_available_from).not_to be_nil
      end
    end
  end

  describe '#seasonal_analysis' do
    let(:seasonal_analysis) { service.seasonal_analysis }

    context 'with gas' do
      it 'produces expected seasonal control analysis' do
        expect(seasonal_analysis.estimated_savings.kwh).to be_within(0.01).of(5789.31)
        expect(seasonal_analysis.estimated_savings.£).to be_within(0.01).of(173.68)
        expect(seasonal_analysis.estimated_savings.co2).to be_within(0.01).of(1056.72)
        expect(seasonal_analysis.heating_on_in_warm_weather_days).to be_within(0.01).of(7.0)

        # extracted expected value here by running the old advice
        # page and dumping variable from AlertSeasonalHeatingSchoolDays
        # this uses a different set of date ranges, than if you run
        # the alert separately.
        expect(seasonal_analysis.percent_of_annual_heating).to be_within(0.01).of(0.03)
      end
    end

    context 'with storage heater' do
      let(:service) do
        described_class.new(meter_collection: @beta_academy, fuel_type: :storage_heater)
      end

      it 'produces expected seasonal control analysis for storage heater' do
        expect(seasonal_analysis.estimated_savings.kwh).to be_within(0.01).of(1857.68)
        expect(seasonal_analysis.estimated_savings.£).to be_within(0.01).of(348.25)
        expect(seasonal_analysis.estimated_savings.co2).to be_within(0.01).of(198.91)
        expect(seasonal_analysis.heating_on_in_warm_weather_days).to be_within(0.01).of(8.0)

        expect(seasonal_analysis.percent_of_annual_heating).to be_within(0.01).of(0.03)
      end
    end
  end
end
