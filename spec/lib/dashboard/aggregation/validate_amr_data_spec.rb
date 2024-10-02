# frozen_string_literal: true

require 'spec_helper'

# module Logging
#  logger.level = :debug
# end

describe ValidateAMRData, type: :service do
  let(:meter_collection)          { @acme_academy }
  let(:meter)                     { meter_collection.meter?(1_591_058_886_735) }
  let(:max_days_missing_data)     { 50 }

  context 'with real data' do
    # using before(:all) here to avoid slow loading of YAML
    before(:all) do
      @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy', validate_and_aggregate: false)
    end

    let(:validator) do
      described_class.new(meter, max_days_missing_data, meter_collection.holidays, meter_collection.temperatures)
    end

    it 'validates' do
      validator.validate(debug_analysis: true)
      expect(validator.data_problems).to be_empty
    end
  end
end
