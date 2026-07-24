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

      it 'uses the school price' do
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

        it 'adds the extra fees' do
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

      it 'uses the contract agreed price' do
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

        it 'adds the extra fees' do
          expect(price).to have_attributes(
            base_price: licence.contract.agreed_school_price,
            metering_fee: licence.product.metering_fee,
            private_account_fee: licence.product.private_account_fee
          )
        end
      end
    end

    context 'when there are no pricing overrides' do
      it 'uses the product base price' do
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

        it 'adds the extra fees' do
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

    context 'with a standard contract period longer than a year' do
      let!(:licence) do
        create(:commercial_licence, school:, contract:, start_date: contract.start_date, end_date: contract.end_date)
      end

      context 'with a two year period' do
        let!(:contract) do
          create(:commercial_contract,
                 product:,
                 start_date: Date.new(2024, 1, 1),
                 end_date: Date.new(2025, 12, 31),
                 licence_period: 'contract',
                 invoice_terms: 'full')
        end

        it 'calculates a price based on the contract period' do
          expect_price_to_match(price, base_price: licence.product.small_school_price * 2.0)
        end
      end

      context 'with an 18 month period' do
        let!(:contract) do
          create(:commercial_contract,
                 product:,
                 start_date: Date.new(2024, 1, 1),
                 end_date: Date.new(2025, 6, 30), # 18 months
                 licence_period: 'contract',
                 invoice_terms: 'full')
        end

        it 'calculates a price based on contract period' do
          full_days = (licence.end_date - licence.start_date).to_i
          length_multiplier = full_days.to_f / 365.0

          expect_price_to_match(price, base_price: licence.product.small_school_price * length_multiplier)
        end
      end
    end

    context 'with a custom contract' do
      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract:,
               start_date: contract.start_date,
               end_date: Commercial::LicenceManager.add_years(contract.start_date, contract.licence_years))
      end

      context 'with a single year term' do
        let!(:contract) do
          create(:commercial_contract,
                 :custom,
                 product:,
                 licence_years: 1.0)
        end

        it 'calculates a price based licence years' do
          expect_price_to_match(price, base_price: licence.product.small_school_price)
        end
      end

      context 'with a two year term' do
        let!(:contract) do
          create(:commercial_contract,
                 :custom,
                 product:,
                 licence_years: 2.0)
        end

        it 'calculates a price based licence years' do
          expect_price_to_match(price, base_price: licence.product.small_school_price * 2.0)
        end
      end

      context 'with a fractional year term' do
        let!(:contract) do
          create(:commercial_contract,
                 :custom,
                 product:,
                 licence_years: 1.75) # 1 year + 9 months
        end

        it 'calculates a price based licence years' do
          expect_price_to_match(price, base_price: licence.product.small_school_price * contract.licence_years)
        end
      end
    end

    context 'with a pro-rata contract' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               start_date: Date.new(2024, 1, 1),
               end_date: Date.new(2024, 12, 31),
               licence_period: 'contract',
               invoice_terms: 'pro_rata')
      end

      context 'when the licence matches the contract dates' do
        let!(:licence) do
          create(:commercial_licence,
                 school:,
                 contract:,
                 start_date: contract.start_date,
                 end_date: contract.end_date)
        end

        it 'calculates the full price' do
          expect_price_to_match(price, base_price: licence.product.small_school_price)
        end
      end

      context 'when the licence is for less than the contract period' do
        let!(:licence) do
          create(:commercial_licence,
                 school:,
                 contract:,
                 start_date: Date.new(2024, 6, 1),
                 end_date: Date.new(2024, 12, 31))
        end

        it 'calculates a pro-rated price' do
          # There are 214 days between 1st June and 31st December, inclusive.
          prorata_multiplier = (licence.end_date - licence.start_date + 1) / 365.0
          expect_price_to_match(price, base_price: licence.product.small_school_price * prorata_multiplier)
        end
      end

      context 'when there are metering and private fees' do
        let!(:school) do
          school = create(:school, number_of_pupils: 600, data_sharing: :private)
          create_list(:electricity_meter, 3, school:)
          create_list(:gas_meter, 3, school:) # 6 meters, 1 over threshold
          school
        end

        it 'prorates all the pricing' do
          # There are 214 days between 1st June and 31st December, inclusive.
          prorata_multiplier = (licence.end_date - licence.start_date + 1) / 365.0

          expect_price_to_match(price, base_price: licence.product.large_school_price * prorata_multiplier,
                                       metering_fee: licence.product.metering_fee * prorata_multiplier,
                                       private_account_fee: licence.product.private_account_fee * prorata_multiplier)
        end
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
