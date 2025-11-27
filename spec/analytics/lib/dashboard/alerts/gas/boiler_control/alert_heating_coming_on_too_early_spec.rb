# frozen_string_literal: true

require 'rails_helper'

describe AlertHeatingComingOnTooEarly do
  subject(:alert) { described_class.new(meter_collection) }

  context 'when during a holiday' do
    it_behaves_like 'a never relevant alert' do
      let(:asof_date) { Date.new(2023, 12, 22) }
      let(:fuel_type) { :gas }
      before { alert.analyse(asof_date) }
    end
  end
end
