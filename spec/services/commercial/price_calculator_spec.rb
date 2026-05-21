# frozen_string_literal: true

require 'rails_helper'

describe Commercial::PriceCalculator do
  let(:service) { described_class.new }

  let!(:product) { create(:commercial_product) }

  describe '#calculate' do
    describe 'when specifying just a product' do
      subject(:price) { service.calculate(product:, number_of_pupils: 100, number_of_meters: 1) }

      it 'calculates the correct price' do
        expect(price).to have_attributes(
          base_price: product.small_school_price,
          metering_fee: 0.0,
          private_account_fee: 0.0
        )
      end

      context 'when school is larger than size threshold' do
        subject(:price) { service.calculate(product:, number_of_pupils: 251, number_of_meters: 1) }

        it 'calculates the correct price' do
          expect(price).to have_attributes(
            base_price: product.large_school_price,
            metering_fee: 0.0,
            private_account_fee: 0.0
          )
        end
      end

      context 'when the account will be private' do
        subject(:price) do
          service.calculate(product:, number_of_pupils: 100, number_of_meters: 1, private_account: true)
        end

        it 'adds on the private account fee' do
          expect(price).to have_attributes(
            base_price: product.small_school_price,
            metering_fee: 0.0,
            private_account_fee: product.private_account_fee
          )
        end
      end

      context 'when there are multiple meters' do
        subject(:price) { service.calculate(product:, number_of_pupils: 100, number_of_meters: 6) }

        it 'adds on the per meter fee' do
          expect(price).to have_attributes(
            base_price: product.small_school_price,
            metering_fee: product.metering_fee,
            private_account_fee: 0.0
          )
        end
      end
    end

    describe 'when specifying a contract' do
      subject(:price) { service.calculate(contract:, number_of_pupils: 100, number_of_meters: 1) }

      let!(:contracted_product) do
        create(:commercial_product,
               small_school_price: 500.0,
               large_school_price: 600,
               size_threshold: 200,
               private_account_fee: 100.0,
               metering_fee: 50.0)
      end
      let(:contract) { create(:commercial_contract, product: contracted_product) }

      it 'calculates the price using the contracted product' do
        expect(price).to have_attributes(
          base_price: contracted_product.small_school_price,
          metering_fee: 0.0,
          private_account_fee: 0.0
        )
      end

      context 'with a fixed agreed school price' do
        let(:contract) { create(:commercial_contract, product: contracted_product, agreed_school_price: 400.0) }

        it 'calculates the correct price' do
          expect(price).to have_attributes(
            base_price: contract.agreed_school_price,
            metering_fee: 0.0,
            private_account_fee: 0.0
          )
        end

        # rubocop:disable RSpec/NestedGroups
        context 'when school is larger than size threshold' do
          subject(:price) { service.calculate(contract:, number_of_pupils: 500, number_of_meters: 1) }

          it 'still uses the fixed price' do
            expect(price).to have_attributes(
              base_price: contract.agreed_school_price,
              metering_fee: 0.0,
              private_account_fee: 0.0
            )
          end
        end

        context 'when the price is zero' do
          let(:contract) { create(:commercial_contract, product: contracted_product, agreed_school_price: 0.0) }

          it 'returns zero for the total price' do
            expect(price.total).to eq(0.0)
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end

      context 'when the account will be private' do
        subject(:price) do
          service.calculate(contract:, number_of_pupils: 100, number_of_meters: 1, private_account: true)
        end

        it 'adds on the private account fee' do
          expect(price).to have_attributes(
            base_price: contracted_product.small_school_price,
            metering_fee: 0.0,
            private_account_fee: contracted_product.private_account_fee
          )
        end
      end

      context 'when there are multiple meters' do
        subject(:price) { service.calculate(contract:, number_of_pupils: 100, number_of_meters: 6) }

        it 'adds on the per meter fee' do
          expect(price).to have_attributes(
            base_price: contracted_product.small_school_price,
            metering_fee: contracted_product.metering_fee,
            private_account_fee: 0.0
          )
        end
      end

      context 'when the contract spans multiple years' do
        let(:contract) do
          create(:commercial_contract, product: contracted_product, end_date: Time.zone.today + 730)
        end

        it 'calculates the price using the contract length' do
          expect(price).to have_attributes(
            base_price: contracted_product.small_school_price * 2.0,
            metering_fee: 0.0,
            private_account_fee: 0.0
          )
        end
      end
    end
  end
end
