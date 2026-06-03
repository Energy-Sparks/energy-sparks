# frozen_string_literal: true

require 'rails_helper'

describe AlertHeatingComingOnTooEarly do
  subject(:alert) { described_class.new(aggregate_meter.meter_collection) }

  context 'when during a holiday' do
    it_behaves_like 'a never relevant alert', :gas, asof_date: Date.new(2023, 12, 22)
  end
end
