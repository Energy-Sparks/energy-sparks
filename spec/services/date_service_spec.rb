# frozen_string_literal: true

require 'rails_helper'

describe DateService do
  describe '#start_of_months', :aggregate_failures do
    it 'returns expected months' do
      expected = %w[2024-01-01 2024-02-01]
      expect(described_class.start_of_months(Date.new(2024, 1, 1), Date.new(2024, 2, 15)).map(&:to_s)).to eq(expected)
      expect(described_class.start_of_months(Date.new(2024, 1, 15), Date.new(2024, 2, 15)).map(&:to_s)).to eq(expected)
      expect(described_class.start_of_months(Date.new(2024, 1, 1), Date.new(2024, 2, 1)).map(&:to_s)).to eq(expected)
      expect(described_class.start_of_months(Date.new(2024, 1, 31), Date.new(2024, 2, 28)).map(&:to_s)).to eq(expected)
    end

    it 'gives an empty response' do
      expect(described_class.start_of_months(Date.new(2024, 1, 1), Date.new(2024, 1, 1)).map(&:to_s)).to eq([])
      expect(described_class.start_of_months(Date.new(2024, 1, 2), Date.new(2024, 1, 1)).map(&:to_s)).to eq([])
      expect(described_class.start_of_months(Date.new(2024, 2, 2), Date.new(2024, 1, 1)).map(&:to_s)).to eq([])
    end
  end
end
