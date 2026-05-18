# frozen_string_literal: true

require 'rails_helper'

describe Commercial::ContractPriceCalculator do
  let(:service) { described_class.new(contract) }

  let!(:product) { create(:commercial_product) }

  # rubocop:disable RSpec/NestedGroups
  describe '#per_school' do
    subject(:price) { service.per_school[school.id][:price] }

    let!(:contract) { create(:commercial_contract, product:, invoice_terms: :full) }
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
      let!(:contract) { create(:commercial_contract, invoice_terms: :full, agreed_school_price: 400.0, product:) }

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

    def expect_price_to_match(price, base_price:, metering_fee: 0.0, private_account_fee: 0.0)
      expect(price.base_price).to be_within(0.0001).of(base_price)
      expect(price.metering_fee).to be_within(0.0001).of(metering_fee)
      expect(price.private_account_fee).to be_within(0.0001).of(private_account_fee)
    end

    context 'with a contract period longer than a year' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               start_date: Date.new(2024, 1, 1),
               end_date: Date.new(2025, 6, 30), # 18 months
               licence_period: 'contract',
               invoice_terms: 'full')
      end

      let!(:licence) do
        create(:commercial_licence, school:, contract:, start_date: contract.start_date, end_date: contract.end_date)
      end

      it 'calculates a price based on contract period' do
        full_days = (licence.end_date - licence.start_date).to_i
        length_multiplier = full_days.to_f / 365.0

        expect_price_to_match(price, base_price: licence.product.small_school_price * length_multiplier)
      end
    end

    # FIXME: licence dates?
    context 'with a custom contract' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               licence_period: 'custom',
               licence_years: 1.75, # 1 year + 9 months
               invoice_terms: 'full')
      end

      let!(:licence) { create(:commercial_licence, school:, contract:) }

      it 'calculates a price based licence years' do
        expect_price_to_match(price, base_price: licence.product.small_school_price * contract.licence_years)
      end
    end

    # TODO
    context 'with a pro-rata contract' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               start_date: Date.new(2024, 1, 1),
               end_date: Date.new(2024, 12, 31),
               licence_period: 'contract',
               invoice_terms: 'pro_rata')
      end

      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract:,
               start_date: Date.new(2024, 7, 1),
               end_date: Date.new(2024, 12, 31))
      end

      it 'calculates a price based on the licence period' do
        full_days = Commercial::Licence.licence_period_days(contract.start_date, contract.end_date)
        used_days = Commercial::Licence.licence_period_days(licence.start_date, licence.end_date)

        prorata_multiplier = used_days.to_f / full_days

        expect_price_to_match(price, base_price: licence.product.small_school_price * prorata_multiplier)
      end
    end

    context 'with a pro-rata contract including metering and private fees' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               start_date: Date.new(2024, 1, 1),
               end_date: Date.new(2024, 12, 31),
               licence_period: 'contract',
               invoice_terms: 'pro_rata')
      end

      let!(:school) do
        school = create(:school, number_of_pupils: 600, data_sharing: :private)
        create_list(:electricity_meter, 3, school:)
        create_list(:gas_meter, 3, school:) # 6 meters, 1 over threshold
        school
      end

      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract:,
               start_date: Date.new(2024, 7, 1),
               end_date: Date.new(2024, 12, 31))
      end

      it 'prorates base, metering, and private fees' do
        full_days = Commercial::Licence.licence_period_days(contract.start_date, contract.end_date)
        used_days = Commercial::Licence.licence_period_days(licence.start_date, licence.end_date)

        length_multiplier = full_days.to_f / 365.0
        proration_multiplier = used_days.to_f / full_days

        total_multiplier = length_multiplier * proration_multiplier

        expect_price_to_match(price, base_price: licence.product.large_school_price * total_multiplier,
                                     metering_fee: licence.product.metering_fee * total_multiplier,
                                     private_account_fee: licence.product.private_account_fee * total_multiplier)
      end
    end
  end

  # rubocop:enable RSpec/NestedGroups

  describe 'totals' do
    subject(:totals) { service.totals }

    let!(:contract) { create(:commercial_contract, product:, invoice_terms: :full) }
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
