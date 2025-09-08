# frozen_string_literal: true

require 'rails_helper'

describe AlertHeatingComingOnTooEarly do
  subject(:alert) { described_class.new(meter_collection) }

  include_context 'with an aggregated meter with tariffs and school times'
  include_context 'with today'

  context 'when during a holiday' do
    let(:asof_date) { Date.new(2023, 12, 22) }

    it 'is never relevant' do
      alert.analyse(asof_date)
      expect(alert.relevance).to eq(:never_relevant)
    end
  end
end
