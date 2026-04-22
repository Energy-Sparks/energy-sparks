# frozen_string_literal: true

require 'rails_helper'

describe Commercial::ContractPriceCalculator do
  let(:service) { described_class.new(contract) }

  let!(:product) { create(:commercial_product) }

  # rubocop:disable RSpec/NestedGroups
  describe 'per_school' do
    subject(:price) { service.per_school[school.id][:price] }

    let!(:contract) { create(:commercial_contract, product:) }
    let!(:school) { create(:school, number_of_pupils: 100, data_sharing: :public) }
    let!(:licence) { create(:commercial_licence, school:, contract:) }

    context 'when the school has a specific price' do
      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract:,
               school_specific_price: 250.0)
      end

      it 'produces pricing data for each school' do
        expect(service.per_school[school.id][:name]).to eq(school.name)
      end

      it 'calculates the specific price' do
        expect(price).to have_attributes(
          base_price: licence.school_specific_price,
          metering_fee: 0.0,
          private_account_fee: 0.0
        )
      end

      context 'when there are additional fees' do
        let(:school) do
          school = create(:school, number_of_pupils: 600, data_sharing: :within_group)
          create_list(:electricity_meter, 3, school:)
          create_list(:gas_meter, 3, school:)
          school
        end

        it 'calculates the expected price' do
          expect(price).to have_attributes(
            base_price: licence.school_specific_price,
            metering_fee: licence.product.metering_fee,
            private_account_fee: licence.product.private_account_fee
          )
        end
      end

      context 'when the school has a free base price' do
        let!(:licence) do
          create(:commercial_licence,
                 school:,
                 school_specific_price: 0.0,
                 contract:)
        end

        it 'returns zero for the total price' do
          expect(price.total).to eq(0.0)
        end

        context 'when there are additional fees' do
          let(:school) do
            school = create(:school, number_of_pupils: 600, data_sharing: :private)
            create_list(:electricity_meter, 3, school:)
            create_list(:gas_meter, 3, school:)
            school
          end

          it 'still returns zero for the total price' do
            expect(price.total).to eq(0.0)
          end
        end
      end
    end

    context 'with an agreed school price in contract' do
      let!(:contract) { create(:commercial_contract, agreed_school_price: 400.0, product:) }

      it 'uses the agreed price' do
        expect(price).to have_attributes(
          base_price: licence.contract.agreed_school_price,
          metering_fee: 0.0,
          private_account_fee: 0.0
        )
      end

      context 'when there are additional fees' do
        let(:school) do
          school = create(:school, number_of_pupils: 600, data_sharing: :private)
          create_list(:electricity_meter, 3, school:)
          create_list(:gas_meter, 3, school:)
          school
        end

        it 'calculates the expected price' do
          expect(price).to have_attributes(
            base_price: licence.contract.agreed_school_price,
            metering_fee: licence.product.metering_fee,
            private_account_fee: licence.product.private_account_fee
          )
        end
      end
    end

    context 'when there are no pricing overrides' do
      it 'calculates the expected price' do
        expect(price).to have_attributes(
          base_price: licence.product.small_school_price,
          metering_fee: 0.0,
          private_account_fee: 0.0
        )
      end

      context 'when there are additional fees' do
        let(:school) do
          school = create(:school, number_of_pupils: 600, data_sharing: :private)
          create_list(:electricity_meter, 3, school:)
          create_list(:gas_meter, 3, school:)
          school
        end

        it 'calculates the expected price' do
          expect(price).to have_attributes(
            base_price: licence.product.large_school_price,
            metering_fee: licence.product.metering_fee,
            private_account_fee: licence.product.private_account_fee
          )
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups

  describe 'totals' do
    subject(:totals) { service.totals }

    let!(:contract) { create(:commercial_contract, product:) }
    let!(:school) { create(:school, number_of_pupils: 100, data_sharing: :public) }
    let!(:licence) { create(:commercial_licence, school:, contract:) }

    it 'calculates the expected price' do
      expect(totals).to have_attributes(
        base_price: licence.product.small_school_price,
        metering_fee: 0.0,
        private_account_fee: 0.0
      )
    end
  end
end
