# frozen_string_literal: true

require 'rails_helper'

describe FloorAreaPupilNumbersBase do
  describe '.value' do
    subject(:numbers) { described_class.new(attributes, :number_of_pupils, :default) }

    context 'with nil attributes' do
      let(:attributes) { nil }

      it { expect(numbers.value).to eq(:default) }
    end

    context 'with empty attributes' do
      let(:attributes) { [] }

      it { expect(numbers.value).to eq(:default) }
    end

    context 'with a single attribute' do
      before { travel_to(Date.new(2025)) }

      let(:attributes) { [{ start_date: Date.new(2025), end_date: Date.new(2026), number_of_pupils: 1 }] }

      it { expect(numbers.value).to eq(1) }
    end

    context 'with multiple attributes' do
      before { travel_to(Date.new(2025)) }

      let(:attributes) do
        [{ start_date: Date.new(2024), end_date: Date.new(2025), number_of_pupils: 10 },
         { start_date: Date.new(2025), end_date: Date.new(2026), number_of_pupils: 20 }]
      end

      it { expect(numbers.value).to eq(20) }

      it { expect(numbers.value(Date.new(2024), Date.new(2026))).to eq(14) }
    end
  end
end
