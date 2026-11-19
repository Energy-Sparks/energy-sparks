# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnergyTariffReminderReport do
  describe '#next_biannual_date' do
    { Date.new(2027, 1, 1) => Date.new(2027, 3, 15),
      Date.new(2027, 3, 14) => Date.new(2027, 3, 15),
      Date.new(2027, 3, 15) => Date.new(2027, 3, 15),
      Date.new(2027, 3, 16) => Date.new(2027, 9, 15),
      Date.new(2027, 9, 14) => Date.new(2027, 9, 15),
      Date.new(2027, 9, 15) => Date.new(2027, 9, 15),
      Date.new(2027, 9, 16) => Date.new(2028, 3, 15),
      Date.new(2027, 12, 31) => Date.new(2028, 3, 15),
      Date.new(2028, 2, 29) => Date.new(2028, 3, 15) }.each do |from, expected|
      it "returns #{expected} on or after #{from}" do
        expect(described_class.new(from:).next_biannual_date).to eq(expected)
      end
    end
  end
end
