# frozen_string_literal: true

require 'rails_helper'

describe Targets::TargetsService do
  let(:meter_collection)        { build(:meter_collection) }
  let(:fuel_type)               { :electricity }
  let(:service)                 { described_class.new(meter_collection, fuel_type) }

  describe '#enough_data' do
    before do
      allow(service).to receive_messages(enough_holidays?: true, enough_temperature_data?: true,
                                         enough_readings_to_calculate_target?: true)
    end

    it 'is enabled by default' do
      expect(service.enough_data_to_set_target?).to be true
    end

    it 'can be disabled by feature flag' do
      allow(ENV).to receive(:[]).with('FEATURE_FLAG_TARGETS_DISABLE_ELECTRICITY').and_return('true')
      expect(service.enough_data_to_set_target?).to be false
    end

    it 'can be enabled by feature flag' do
      allow(ENV).to receive(:[]).with('FEATURE_FLAG_TARGETS_DISABLE_ELECTRICITY').and_return('false')
      expect(service.enough_data_to_set_target?).to be true
    end
  end
end
