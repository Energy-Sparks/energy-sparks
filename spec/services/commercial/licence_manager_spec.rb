# frozen_string_literal: true

require 'rails_helper'

describe Commercial::LicenceManager do
  let(:school) { create(:school, data_enabled: false) }

  let(:service) { described_class.new(school) }

  describe '.licence_dates' do
    subject(:dates) { described_class.licence_dates(contract) }

    context 'when the licence_period is "contract"' do
      context "when invoice_terms are 'full'" do
        let!(:contract) do
          create(:commercial_contract, start_date: Time.zone.yesterday, status: :confirmed, licence_period: :contract,
                                       invoice_terms: :full)
        end

        it { expect(dates[:start_date]).to eq(contract.start_date) }
        it { expect(dates[:end_date]).to eq(contract.end_date) }

        # rubocop:disable RSpec/NestedGroups
        context 'with an invoiced school' do
          before do
            create(:commercial_licence, contract:, status: :invoiced)
          end

          it { expect(dates[:start_date]).to eq(contract.start_date) }
          it { expect(dates[:end_date]).to eq(contract.end_date) }
        end
        # rubocop:enable RSpec/NestedGroups
      end

      context "when invoice_terms are 'pro_rata'" do
        let!(:contract) do
          create(:commercial_contract, start_date: Time.zone.yesterday, status: :confirmed, licence_period: :contract,
                                       invoice_terms: :pro_rata)
        end

        it { expect(dates[:start_date]).to eq(contract.start_date) }
        it { expect(dates[:end_date]).to eq(contract.end_date) }

        # rubocop:disable RSpec/NestedGroups
        context 'with an invoiced school' do
          before do
            create(:commercial_licence, contract:, status: :invoiced)
          end

          it { expect(dates[:start_date]).to eq(Time.zone.today) }
          it { expect(dates[:end_date]).to eq(contract.end_date) }
        end
        # rubocop:enable RSpec/NestedGroups
      end
    end

    context 'when the licence_period is "custom"' do
      let!(:contract) do
        create(:commercial_contract, :custom, start_date: Time.zone.yesterday, status: :confirmed)
      end

      it { expect(dates[:start_date]).to eq(Time.zone.today) }
      it { expect(dates[:end_date]).to eq(Time.zone.today.next_year - 1.day) }

      context 'when there is a fractional licence_years period' do
        let!(:contract) do
          create(:commercial_contract, :custom, licence_years: 1.5)
        end

        it { expect(dates[:start_date]).to eq(Time.zone.today) }
        it { expect(dates[:end_date]).to eq(Time.zone.today + 18.months - 1.day) }
      end
    end
  end

  describe '#school_onboarded' do
    subject(:licence) { service.school_onboarded(contract) }

    context 'when the licence_period is "contract"' do
      let!(:contract) { create(:commercial_contract, status: :confirmed, licence_period: :contract) }

      it 'creates a confirmed licence' do
        expect(licence).to have_attributes({
                                             contract:,
                                             school:,
                                             status: 'confirmed',
                                             start_date: Time.zone.today,
                                             end_date: contract.end_date
                                           })
      end

      context 'when school is data enabled' do
        let(:school) { create(:school, data_enabled: true) }

        it 'creates a licence that is pending invoicing' do
          expect(licence).to have_attributes({
                                               contract:,
                                               school:,
                                               status: 'pending_invoice',
                                               start_date: Time.zone.today,
                                               end_date: contract.end_date
                                             })
        end
      end

      context 'when the contract is not confirmed' do
        let!(:contract) { create(:commercial_contract, status: :provisional, licence_period: :contract) }

        it 'created a provisional licence' do
          expect(licence).to have_attributes({
                                               contract:,
                                               school:,
                                               status: 'provisional',
                                               start_date: contract.start_date,
                                               end_date: contract.end_date
                                             })
        end
      end
    end

    context 'when the licence period is "custom"' do
      let!(:contract) do
        create(:commercial_contract, :custom, status: :confirmed, licence_years: 1.0)
      end

      it 'creates the expected licence dates' do
        expect(licence).to have_attributes({
                                             contract:,
                                             school:,
                                             status: 'confirmed',
                                             start_date: Time.zone.today,
                                             end_date: Time.zone.today + 364.days
                                           })
      end

      context 'when school is data enabled' do
        let(:school) { create(:school, data_enabled: true) }

        it 'creates a licence that is pending invoicing' do
          expect(licence).to have_attributes({
                                               contract:,
                                               school:,
                                               status: 'pending_invoice',
                                               start_date: Time.zone.today,
                                               end_date: Time.zone.today + 364.days
                                             })
        end
      end

      context 'when there is a fractional licence_years period' do
        let!(:contract) do
          create(:commercial_contract, :custom, status: :confirmed, licence_years: 1.5)
        end

        it 'creates the expected licence dates' do
          expect(licence).to have_attributes({
                                               contract:,
                                               school:,
                                               status: 'confirmed',
                                               start_date: Time.zone.today,
                                               end_date: Time.zone.today + 18.months - 1.day
                                             })
        end
      end
    end
  end

  describe '#school_made_data_enabled' do
    subject(:updated_licence) { service.school_made_data_enabled }

    context 'when the licence_period is "contract"' do
      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract: create(:commercial_contract, licence_period: :contract),
               status: :confirmed)
      end

      context 'when invoice terms are full' do
        it 'updates the licence status only' do
          expect(updated_licence).to have_attributes(
            status: 'pending_invoice',
            start_date: licence.start_date,
            end_date: licence.end_date
          )
        end
      end

      context 'when invoice terms are pro_rata' do
        let!(:licence) do
          create(:commercial_licence,
                 school:,
                 start_date: Time.zone.yesterday,
                 contract: create(:commercial_contract, licence_period: :contract, invoice_terms: :pro_rata),
                 status: :confirmed)
        end

        it 'updates the licence start date' do
          expect(updated_licence).to have_attributes(
            status: 'pending_invoice',
            start_date: Time.zone.today,
            end_date: licence.end_date
          )
        end
      end

      context 'when the status had already changed' do
        let!(:licence) do
          create(:commercial_licence,
                 school:,
                 contract: create(:commercial_contract, licence_period: :contract),
                 status: :invoiced) # paid in advance
        end

        it 'does not change the status' do
          expect(updated_licence).to have_attributes(
            status: 'invoiced',
            start_date: licence.start_date,
            end_date: licence.end_date
          )
        end
      end
    end

    context 'when the licence period is "custom"' do
      let!(:licence) do
        create(:commercial_licence,
               school:,
               contract: create(:commercial_contract, :custom, licence_years: 1.0),
               status: :confirmed)
      end

      it 'updates the licence status and dates' do
        expect(updated_licence).to have_attributes(
          status: 'pending_invoice',
          start_date: Time.zone.today,
          end_date: Time.zone.today + 364.days
        )
      end

      context 'when the status had already changed' do
        let!(:licence) do
          create(:commercial_licence,
                 school:,
                 contract: create(:commercial_contract, :custom, licence_years: 1.0),
                 status: :invoiced)
        end

        it 'does not change the status' do
          expect(updated_licence).to have_attributes(
            status: 'invoiced',
            start_date: Time.zone.today,
            end_date: Time.zone.today + 364.days
          )
        end
      end

      context 'when there is a fractional licence_years period' do
        let!(:licence) do
          create(:commercial_licence,
                 school:,
                 contract: create(:commercial_contract, :custom, licence_years: 1.75),
                 status: :confirmed)
        end

        it 'creates the expected licence dates' do
          expect(updated_licence).to have_attributes(
            status: 'pending_invoice',
            start_date: Time.zone.today,
            end_date: Time.zone.today + 21.months - 1.day
          )
        end
      end
    end
  end

  describe '#contract_renewed' do
    subject(:licence) { service.contract_renewed(contract, original_licence) }

    let(:original_licence) { create(:commercial_licence, contract:, school_specific_price: 0.0) }

    context 'when the licence_period is "contract"' do
      let!(:contract) { create(:commercial_contract, status: :provisional, licence_period: :contract) }

      it 'created a provisional licence' do
        expect(licence).to have_attributes({
                                             contract:,
                                             school:,
                                             status: 'provisional',
                                             start_date: contract.start_date,
                                             end_date: contract.end_date
                                           })
      end

      it 'copies over the comments and school price' do
        expect(licence).to have_attributes({
                                             comments: original_licence.comments,
                                             school_specific_price: original_licence.school_specific_price
                                           })
      end
    end

    context 'when the licence period is "custom"' do
      let!(:contract) do
        create(:commercial_contract,
               :custom,
               status: :provisional,
               start_date: Date.new(2026, 9, 1),
               end_date: Date.new(2027, 8, 31),
               licence_years: 1.0)
      end

      it 'creates the expected licence dates' do
        expect(licence).to have_attributes({
                                             contract:,
                                             school:,
                                             status: 'provisional',
                                             start_date: contract.start_date,
                                             end_date: contract.end_date
                                           })
      end

      it 'copies over the comments and school price' do
        expect(licence).to have_attributes({
                                             comments: original_licence.comments,
                                             school_specific_price: original_licence.school_specific_price
                                           })
      end

      context 'when there is a fractional licence_years period' do
        let!(:contract) do
          create(:commercial_contract,
                 :custom,
                 status: :provisional,
                 start_date: Date.new(2026, 9, 1),
                 end_date: Date.new(2027, 8, 31),
                 licence_years: 1.5)
        end

        it 'creates the expected licence dates' do
          expect(licence).to have_attributes({
                                               contract:,
                                               school:,
                                               status: 'provisional',
                                               start_date: Date.new(2026, 9, 1),
                                               end_date: Date.new(2026, 9, 1) + 18.months - 1.day
                                             })
        end
      end
    end
  end
end
