# frozen_string_literal: true

require 'rails_helper'

describe Commercial::PriceCalculator do
  let(:service) { described_class.new }

  describe '#calculate' do
    describe 'when specifying just a product' do
      it 'calculates the correct price'

      context 'when school is larger than size threshold' do
        it 'calculates the correct price'
      end

      context 'when the account will be private' do
        it 'adds on the private account fee'
      end

      context 'when there are multiple meters' do
        it 'adds on the per meter fee'
      end
    end

    describe 'when specifying a contract' do
      it 'calculates the price using the contracted product'

      context 'with a school specific price' do
        it 'calculates the correct price'

        context 'when school is larger than size threshold' do
          it 'calculates the correct price'
        end
      end

      context 'when the account will be private' do
        it 'adds on the private account fee'
      end

      context 'when there are multiple meters' do
        it 'adds on the per meter fee'
      end
    end
  end

  describe '#for_school' do
    it 'calculates the price based on the school data'
  end

  describe '#for_school_renewal' do
    describe 'when there is a current licence' do
      context 'when the school has a specific price' do
        it 'calculates the specific price'

        context 'when there are additional fees' do
          it 'calculates the expected price'
        end

        context 'when the school has a free base price' do
          it 'returns zero for the total price'

          context 'when there are additional fees' do
            it 'returns zero for the total price'
          end
        end
      end

      describe 'with an agreed school price' do
        it 'uses the agreed price'

        context 'when there are additional fees' do
          it 'calculates the expected price'
        end
      end

      describe 'when there are no override prices' do
        it 'calculates the expected price'

        context 'when there are additional fees' do
          it 'calculates the expected price'
        end
      end
    end
  end
end
