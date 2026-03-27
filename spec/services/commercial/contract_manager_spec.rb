# frozen_string_literal: true

require 'rails_helper'

describe Commercial::ContractManager do
  let!(:contract) { create(:commercial_contract, status: :confirmed) }
  let!(:admin) { create(:admin) }

  let(:service) { described_class.new(contract, admin) }

  describe '#renew_licences' do
    subject(:licence) { Commercial::Licence.last }

    let!(:original_contract) { create(:commercial_contract) }
    let!(:old_licence) { create(:commercial_licence, contract: original_contract, school_specific_price: 100.0) }

    before do
      service.renew_licences(original_contract)
    end

    it 'creates a new licence and copies details' do
      expect(licence).to have_attributes(
        contract:,
        school: old_licence.school,
        school_specific_price: old_licence.school_specific_price
      )
    end
  end

  describe '#cascade_updates_to_licences' do
    context 'with invoiced licences' do
      let!(:licence) { create(:commercial_licence, contract:, status: :invoiced) }

      it 'does not update the licence' do
        expect { service.cascade_updates_to_licences }
          .not_to(change { licence.reload.slice(:updated_by, :status, :start_date) })
      end
    end

    context 'with provisional licences' do
      let!(:licence) { create(:commercial_licence, contract:, status: :provisional, start_date: 1.year.ago) }

      before { service.cascade_updates_to_licences }

      it 'updates the licence' do
        expect(licence.reload).to have_attributes(
          updated_by: admin,
          start_date: contract.start_date,
          status: 'confirmed'
        )
      end
    end
  end
end
