# frozen_string_literal: true

require 'rails_helper'

describe Costs::AccountingCostsService, type: :service do
  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  let(:service) { described_class.new(@acme_academy.aggregated_electricity_meters) }

  it 'has enough data' do
    expect(service.enough_data?).to be true
    expect(service.data_available_from).to eq nil
  end

  it 'returns the expected values' do
    annual_costs = service.annual_cost
    expect(annual_costs.£).to be_within(0.01).of(62_593.02)
    expect(annual_costs.days.to_i).to eq 366
    expect(annual_costs.start_date).to eq Date.new(2022, 10, 11)
    expect(annual_costs.end_date).to eq Date.new(2023, 10, 11)
  end
end
