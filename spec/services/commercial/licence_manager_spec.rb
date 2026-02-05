# frozen_string_literal: true

require 'rails_helper'

describe Commercial::LicenceManager do
  let(:school) { create(:school) }

  let(:service) { described_class.new(school) }

  describe '#school_onboarded' do
    subject(:licence) { service.school_onboarded(contract) }

    context 'when the licence_period is "contract"' do
      let!(:contract) { create(:commercial_contract, status: :confirmed, licence_period: :contract) }

      it 'creates a confirmed licence' do
        expect(licence).to have_attributes({
          contract:,
          school:,
          status: 'confirmed',
          start_date: contract.start_date,
          end_date: contract.end_date
        })
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
        create(:commercial_contract,
               status: :confirmed,
               licence_period: :custom,
               licence_years: 1.0)
      end

      it 'creates the expected licence dates' do
        expect(licence).to have_attributes({
          contract:,
          school:,
          status: 'confirmed',
          start_date: Time.zone.today,
          end_date: Time.zone.today + 1.year
        })
      end

      context 'when there is a fractional licence_years period' do
        let!(:contract) do
          create(:commercial_contract,
                 status: :confirmed,
                 licence_period: :custom,
                 licence_years: 1.5)
        end

        it 'creates the expected licence dates' do
          expect(licence).to have_attributes({
            contract:,
            school:,
            status: 'confirmed',
            start_date: Time.zone.today,
            end_date: Time.zone.today + 18.months
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

      it 'updates the licence status only' do
        expect(updated_licence).to have_attributes(
          status: 'pending_invoice',
          start_date: licence.start_date,
          end_date: licence.end_date
        )
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
          contract: create(:commercial_contract, licence_period: :custom, licence_years: 1.0),
          status: :confirmed)
      end

      it 'updates the licence status and dates' do
        expect(updated_licence).to have_attributes(
          status: 'pending_invoice',
          start_date: Time.zone.today,
          end_date: Time.zone.today + 1.year
        )
      end

      context 'when the status had already changed' do
        let!(:licence) do
          create(:commercial_licence,
            school:,
            contract: create(:commercial_contract, licence_period: :custom, licence_years: 1.0),
            status: :invoiced)
        end

        it 'does not change the status' do
          expect(updated_licence).to have_attributes(
            status: 'invoiced',
            start_date: Time.zone.today,
            end_date: Time.zone.today + 1.year
          )
        end
      end

      context 'when there is a fractional licence_years period' do
        let!(:licence) do
          create(:commercial_licence,
            school:,
            contract: create(:commercial_contract, licence_period: :custom, licence_years: 1.75),
            status: :confirmed)
        end

        it 'creates the expected licence dates' do
          expect(updated_licence).to have_attributes(
            status: 'pending_invoice',
            start_date: Time.zone.today,
            end_date: Time.zone.today + 21.months
          )
        end
      end
    end
  end
end
