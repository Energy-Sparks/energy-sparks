# frozen_string_literal: true

require 'rails_helper'

describe Commercial::ContractPriceCalculator do
  let(:service) { described_class.new(contract) }

  let!(:product) { create(:commercial_product) }

  # rubocop:disable RSpec/NestedGroups
  describe '#per_school' do
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

    # TODO
    context 'with a contract period longer than a year' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               start_date: Date.new(2024, 1, 1),
               end_date: Date.new(2025, 6, 30), # 18 months
               licence_period: 'contract',
               invoice_terms: 'full')
      end

      let!(:school) { create(:school, number_of_pupils: 100, data_sharing: :public) }
      let!(:licence) { create(:commercial_licence, school:, contract:) }

      it 'calculates a price based on contract period' do
        expected_base = licence.product.small_school_price

        full_days = (contract.end_date - contract.start_date).to_i
        length_multiplier = full_days.to_f / 365.0

        expect(price.base_price).to be_within(0.0001).of(expected_base * length_multiplier)
        expect(price.metering_fee).to eq(0.0)
        expect(price.private_account_fee).to eq(0.0)
      end
    end

    # TODO
    context 'with a custom contract' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               licence_period: 'custom',
               licence_years: 1.75, # 1 year + 9 months
               invoice_terms: 'full')
      end

      let!(:school) { create(:school, number_of_pupils: 100, data_sharing: :public) }
      let!(:licence) { create(:commercial_licence, school:, contract:) }

      it 'calculates a price based on the month-granular licence years' do
        expected_base = licence.product.small_school_price

        # Month-granular full period: 1 year + 9 months
        full_end = contract.start_date.advance(years: 1, months: 9) - 1.day
        full_days = (full_end - contract.start_date).to_i

        length_multiplier = full_days.to_f / 365.0

        expect(price.base_price).to be_within(0.0001).of(expected_base * length_multiplier)
        expect(price.metering_fee).to eq(0.0)
        expect(price.private_account_fee).to eq(0.0)
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

      let!(:school) { create(:school, number_of_pupils: 100, data_sharing: :public) }

      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract:,
               start_date: Date.new(2024, 7, 1),
               end_date: Date.new(2024, 12, 31))
      end

      it 'calculates a price based on the licence period' do
        expected_base = licence.product.small_school_price

        full_days = (contract.end_date - contract.start_date).to_i
        used_days = (licence.end_date - licence.start_date).to_i

        length_multiplier = full_days.to_f / 365.0
        proration_multiplier = used_days.to_f / full_days

        total_multiplier = length_multiplier * proration_multiplier

        expect(price.base_price).to be_within(0.0001).of(expected_base * total_multiplier)
        expect(price.metering_fee).to eq(0.0)
        expect(price.private_account_fee).to eq(0.0)
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
        create_list(:gas_meter, 3, school:) # 6 meters → 1 over threshold
        school
      end

      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract:,
               start_date: Date.new(2024, 7, 1),
               end_date: Date.new(2024, 12, 31))
      end

      it 'prorates base, metering, and private fees using month-granular logic' do
        expected_base = licence.product.large_school_price
        expected_metering = licence.product.metering_fee # 1 extra meter
        expected_private = licence.product.private_account_fee

        # Month-granular full period for contract-based licences = exact contract dates
        full_days = (contract.end_date - contract.start_date).to_i

        used_days = (licence.end_date - licence.start_date).to_i

        length_multiplier = full_days.to_f / 365.0
        proration_multiplier = used_days.to_f / full_days

        total_multiplier = length_multiplier * proration_multiplier

        expect(price.base_price).to be_within(0.0001).of(expected_base * total_multiplier)
        expect(price.metering_fee).to be_within(0.0001).of(expected_metering * total_multiplier)
        expect(price.private_account_fee).to be_within(0.0001).of(expected_private * total_multiplier)
      end
    end

    context 'with a custom contract and pro-rata terms' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               licence_period: 'custom',
               licence_years: 1.5, # 1 year + 6 months
               invoice_terms: 'pro_rata')
      end

      let!(:school) { create(:school, number_of_pupils: 100, data_sharing: :public) }

      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract:,
               start_date: contract.start_date.advance(years: 1, months: 3),
               end_date: contract.start_date.advance(years: 1, months: 6) - 1.day)
      end

      it 'calculates a price based on used days within the custom licence period' do
        expected_base = licence.product.small_school_price

        # Full custom period: 1 year + 6 months
        full_end = contract.start_date.advance(years: 1, months: 6) - 1.day
        full_days = (full_end - contract.start_date).to_i

        used_days = (licence.end_date - licence.start_date).to_i

        length_multiplier = full_days.to_f / 365.0
        proration_multiplier = used_days.to_f / full_days

        total_multiplier = length_multiplier * proration_multiplier

        expect(price.base_price).to be_within(0.0001).of(expected_base * total_multiplier)
        expect(price.metering_fee).to eq(0.0)
        expect(price.private_account_fee).to eq(0.0)
      end
    end

    context 'with a custom contract, pro-rata terms, and additional fees' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               licence_period: 'custom',
               licence_years: 1.5, # 1 year + 6 months
               invoice_terms: 'pro_rata')
      end

      let!(:school) do
        school = create(:school, number_of_pupils: 600, data_sharing: :private)
        create_list(:electricity_meter, 3, school:)
        create_list(:gas_meter, 3, school:) # 6 meters → 1 extra
        school
      end

      let!(:licence) do
        # Licence uses the final 3 months of the 18‑month custom period
        create(:commercial_licence,
               school:,
               contract:,
               start_date: contract.start_date.advance(years: 1, months: 3),
               end_date: contract.start_date.advance(years: 1, months: 6) - 1.day)
      end

      it 'prorates base, metering, and private fees using month-granular logic' do
        expected_base     = licence.product.large_school_price
        expected_metering = licence.product.metering_fee
        expected_private  = licence.product.private_account_fee

        # Full custom period: 1 year + 6 months
        full_end  = contract.start_date.advance(years: 1, months: 6) - 1.day
        full_days = (full_end - contract.start_date).to_i

        used_days = (licence.end_date - licence.start_date).to_i

        length_multiplier    = full_days.to_f / 365.0
        proration_multiplier = used_days.to_f / full_days
        total_multiplier     = length_multiplier * proration_multiplier

        expect(price.base_price).to be_within(0.0001).of(expected_base * total_multiplier)
        expect(price.metering_fee).to be_within(0.0001).of(expected_metering * total_multiplier)
        expect(price.private_account_fee).to be_within(0.0001).of(expected_private * total_multiplier)
      end
    end

    context 'with a contract period spanning a leap year' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               start_date: Date.new(2024, 1, 1), # leap year
               end_date: Date.new(2025, 1, 1),
               licence_period: 'contract',
               invoice_terms: 'full')
      end

      let!(:school)   { create(:school, number_of_pupils: 100, data_sharing: :public) }
      let!(:licence)  { create(:commercial_licence, school:, contract:) }

      it 'calculates a month-granular length multiplier including Feb 29' do
        expected_base = licence.product.small_school_price

        full_days = (contract.end_date - contract.start_date).to_i # includes Feb 29
        length_multiplier = full_days.to_f / 365.0

        expect(price.base_price).to be_within(0.0001).of(expected_base * length_multiplier)
      end
    end

    context 'with a custom contract spanning a leap year' do
      let!(:contract) do
        create(:commercial_contract,
               product:,
               start_date: Date.new(2023, 7, 1),
               licence_period: 'custom',
               licence_years: 1.0, # 1 year → includes Feb 29, 2024
               invoice_terms: 'full')
      end

      let!(:school)  { create(:school, number_of_pupils: 100, data_sharing: :public) }
      let!(:licence) { create(:commercial_licence, school:, contract:) }

      it 'calculates a month-granular custom period including leap-day effects' do
        expected_base = licence.product.small_school_price

        full_end  = contract.start_date.advance(years: 1) - 1.day
        full_days = (full_end - contract.start_date).to_i # includes Feb 29, 2024

        length_multiplier = full_days.to_f / 365.0

        expect(price.base_price).to be_within(0.0001).of(expected_base * length_multiplier)
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
