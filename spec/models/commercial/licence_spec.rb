# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Licence do
  include ActiveJob::TestHelper

  describe 'validations' do
    it_behaves_like 'a temporal ranged model'
    it_behaves_like 'a date ranged model'

    describe 'when destroying' do
      context 'with invoiced status' do
        let!(:licence) { create(:commercial_licence, status: :invoiced) }

        it 'does not allow the licence to be destroyed' do
          expect(licence.destroy).to be(false)
          expect(licence.errors[:base]).to include('Cannot delete an invoiced licence')
          expect(licence).to be_persisted
        end
      end

      context 'when provisional status' do
        let!(:licence) { create(:commercial_licence, status: :provisional) }

        it 'allows the licence to be destroyed' do
          expect { licence.destroy }.to change(Commercial::Licence, :count).by(-1)
        end
      end
    end
  end

  describe '#status_colour' do
    it { expect(create(:commercial_licence, status: :provisional).status_colour).to eq(:warning) }
    it { expect(create(:commercial_licence, status: :confirmed).status_colour).to eq(:info) }
    it { expect(create(:commercial_licence, status: :pending_invoice).status_colour).to eq(:danger) }
    it { expect(create(:commercial_licence, status: :invoiced).status_colour).to eq(:success) }
  end

  describe '#dates_will_automatically_change?' do
    let!(:school) { create(:school, :with_school_group, data_enabled: false) }
    let!(:licence) { create(:commercial_licence, contract:, school:) }

    context 'when licence_period is contract' do
      let!(:contract) { create(:commercial_contract, licence_period: :contract) }

      it { expect(licence.dates_will_automatically_change?).to be(false) }
    end

    context 'when licence_period is custom' do
      let!(:contract) { create(:commercial_contract, licence_period: :custom) }

      it { expect(licence.dates_will_automatically_change?).to be(true) }

      context 'with new licence' do
        it 'returns false' do
          licence = build(:commercial_licence, contract:, school:)
          expect(licence.dates_will_automatically_change?).to be(false)
        end
      end

      context 'with data enabled school' do
        let!(:school) { create(:school, :with_school_group, data_enabled: true) }

        it { expect(licence.dates_will_automatically_change?).to be(false) }
      end
    end
  end

  describe '#filtered' do
    let(:school_a) { create(:school, :with_school_grouping, group: create(:school_group)) }
    let(:school_b) { create(:school, :with_school_grouping, group: create(:school_group)) }

    let(:licence_school_a) { create(:commercial_licence, school: school_a, start_date: Date.yesterday) }
    let(:licence_school_b) { create(:commercial_licence, school: school_b) }

    context 'with :current' do
      subject(:licences) { described_class.filtered(:current) }

      it { expect(licences).to contain_exactly(licence_school_a, licence_school_b) }

      context 'with school group' do
        subject(:licences) { described_class.filtered(:current, Time.zone.today, school_a.organisation_group.id) }

        it { expect(licences).to contain_exactly(licence_school_a) }
      end
    end

    context 'with :expiring' do
      let(:licence_school_a) { create(:commercial_licence, school: school_a, end_date: Time.zone.today + 1) }

      subject(:licences) { described_class.filtered(:expiring, Time.zone.today + 7) }

      it { expect(licences).to contain_exactly(licence_school_a) }
    end
  end
end
