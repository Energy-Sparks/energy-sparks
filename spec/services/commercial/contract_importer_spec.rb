require 'rails_helper'

describe Commercial::ContractImporter do
  subject(:service) { described_class.new(import_user:) }

  let!(:product) { create(:commercial_product) }
  let!(:import_user) { create(:admin) }

  let(:start_date) { Date.new(2025, 9, 1) }
  let(:end_date) { Date.new(2026, 8, 31) }

  shared_examples 'a correctly imported contract' do
    subject(:contract) do
      service.import(
        product_name: product.name,
        contract_holder: contract_holder.name,
        name: 'My Contract',
        start_date: start_date.iso8601,
        end_date: end_date.iso8601,
        licence_period: 'contract',
        licence_years: 1,
        invoice_terms: 'pro_rata',
        agreed_school_price: 600.0
      )
    end

    it 'creates expected contract' do
      expect(contract).to have_attributes(
        product:,
        contract_holder:,
        name: 'My Contract',
        start_date:,
        end_date:,
        comments: "Imported on #{Time.zone.today}",
        status: 'confirmed',
        agreed_school_price: 600.0,
        number_of_schools: 1,
        licence_period: 'contract',
        licence_years: 1,
        invoice_terms: 'pro_rata',
        created_by: import_user
      )
    end

    context 'when contract exists with same dates' do
      let!(:existing_contract) { create(:commercial_contract, product:, contract_holder:, start_date:, end_date:) }

      it 'updates the existing contract' do
        expect(contract).to have_attributes(
          product:,
          contract_holder:,
          name: 'My Contract',
          start_date:,
          end_date:,
          comments: "Imported on #{Time.zone.today}",
          status: 'confirmed',
          agreed_school_price: 600.0,
          number_of_schools: 1,
          created_by: existing_contract.created_by,
          updated_by: import_user
        )
      end
    end

    context 'when contract exists with different dates' do
      let!(:existing_contract) { create(:commercial_contract, product:, contract_holder:) }

      it 'creates a new contract' do
        expect { contract }.to change(Commercial::Contract, :count).from(1).to(2)
      end
    end

    context 'when product doesnt exist' do
      subject(:contract) do
        service.import(
          product_name: 'Other product',
          contract_holder: contract_holder.name,
          name: 'My Contract',
          start_date: start_date.iso8601,
          end_date: end_date.iso8601,
          agreed_school_price: 600.0
        )
      end

      it 'does not create contract' do
        expect(contract).to be_nil
      end
    end
  end

  describe '#import' do
    context 'with Funder contract' do
      let!(:contract_holder) { create(:funder) }

      it_behaves_like 'a correctly imported contract'
    end

    context 'with SchoolGroup contract' do
      let!(:contract_holder) { create(:school_group) }

      it_behaves_like 'a correctly imported contract'
    end

    context 'with School contract' do
      let!(:contract_holder) { create(:school, :with_school_group) }

      it_behaves_like 'a correctly imported contract'
    end

    context 'when finding contract holder by name' do
      context 'when there is a Funder and a School Group' do
        let!(:contract_holder) { create(:funder) }
        let!(:school_group) { create(:school_group, name: contract_holder.name) }

        it_behaves_like 'a correctly imported contract'
      end
    end
  end
end
