# frozen_string_literal: true

require 'rails_helper'

describe Costs::TariffInformationService, type: :service do
  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  let(:meter)             { @acme_academy.aggregated_electricity_meters }
  let(:analysis_end_date) { meter.amr_data.end_date }
  let(:analysis_start_date) { [analysis_end_date - 365 - 364, meter.amr_data.start_date].max }
  let(:service) { described_class.new(meter, analysis_start_date, analysis_end_date) }

  context 'when checking tariff coverage' do
    it 'has expected coverage' do
      expect(service.incomplete_coverage?).to be false
      expect(service.percentage_with_real_tariffs).to eq 0.0
      expect(service.periods_with_missing_tariffs).to eq [[Date.new(2021, 10, 12), Date.new(2023, 10, 11)]]
      expect(service.periods_with_tariffs).to eq []
    end
  end

  describe '#tariffs' do
    let(:meter) { @acme_academy.meter?('1580001320420') }

    let(:first_range)  { Date.new(2022, 4, 1)..Date.new(2023, 10, 11) }
    let(:second_range) { Date.new(2021, 10, 12)..Date.new(2022, 3, 31) }

    it 'returns list of tariffs' do
      tariffs = service.tariffs

      first_tariff = tariffs[first_range]
      expect(first_tariff).not_to be_nil
      expect(first_tariff.name).to eq 'System Wide Electricity Accounting Tariff'
      expect(first_tariff.fuel_type).to eq :electricity
      expect(first_tariff.type).to eq :flat
      expect(first_tariff.source).to eq :manually_entered
      expect(first_tariff.real).to eq true

      second_tariff = tariffs[second_range]
      expect(second_tariff).not_to be_nil
      expect(second_tariff.name).to eq 'EDF Differential Tariff 21-22'
      expect(second_tariff.fuel_type).to eq :electricity
      expect(second_tariff.type).to eq :differential
      expect(second_tariff.source).to eq :manually_entered
      expect(second_tariff.start_date).to eq Date.new(2020, 4, 1)
      expect(second_tariff.end_date).to eq Date.new(2022, 3, 31)
      expect(second_tariff.real).to eq true
    end
  end
end
