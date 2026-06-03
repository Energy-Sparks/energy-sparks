# frozen_string_literal: true

require 'rails_helper'

describe Heating::HeatingModelFactory do
  let(:asof_date)      { Date.new(2022, 2, 1) }
  let(:factory)        { described_class.new(@acme_academy.aggregated_heat_meters, asof_date) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#create_model' do
    it 'creates a model' do
      model = factory.create_model
      # Test school has enough gas data
      expect(model).not_to be_nil
      expect(model.enough_samples_for_good_fit).to be true
      expect(model.includes_school_day_heating_models?).to be true
    end
  end
end
