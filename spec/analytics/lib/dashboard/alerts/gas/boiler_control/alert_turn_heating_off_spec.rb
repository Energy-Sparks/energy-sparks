# frozen_string_literal: true

require 'rails_helper'
require_relative '../../turn_heating_off_shared'

RSpec.describe AlertTurnHeatingOff do
  subject(:alert) { described_class.new(meter_collection) }

  it_behaves_like 'an EST-aware turn-heating-off alert', fuel_type: :gas

  it_behaves_like 'a never relevant alert', :electricity
end
