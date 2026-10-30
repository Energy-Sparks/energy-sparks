# frozen_string_literal: true

require 'rails_helper'
require_relative '../turn_heating_off_shared'

RSpec.describe AlertTurnHeatingOffStorageHeaters do
  subject(:alert) { described_class.new(meter_collection) }

  it_behaves_like 'an EST-aware turn-heating-off alert', fuel_type: :storage_heaters do
    before { allow(meter_collection).to receive(:storage_heaters?).and_return(true) }
  end

  it_behaves_like 'a never relevant alert', :gas
end
