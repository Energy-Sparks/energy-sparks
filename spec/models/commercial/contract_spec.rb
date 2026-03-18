# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Contract do
  include ActiveJob::TestHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_numericality_of(:number_of_schools).is_greater_than(0) }

    it_behaves_like 'a temporal ranged model'
    it_behaves_like 'a date ranged model'
    it_behaves_like 'has a contract holder'

    context 'when destroying' do
      let!(:contract) { create(:commercial_contract) }

      it 'allows contracts to be deleted' do
        expect { contract.destroy }.to change(Commercial::Contract, :count).by(-1)
      end

      context 'with invoiced licences' do
        before do
          create(:commercial_licence, contract:, status: :invoiced)
        end

        it 'does not allow the contract to be destroyed' do
          expect(contract.destroy).to be(false)
          expect(contract.errors[:base]).to include('Cannot delete a contract with an invoiced licence')
          expect(contract).to be_persisted
        end
      end

      context 'with confirmed licences' do
        before do
          create(:commercial_licence, contract:, status: :confirmed)
        end

        it 'allows contract to be deleted' do
          expect { contract.destroy }.to change(Commercial::Contract, :count).by(-1)
        end
      end
    end

    describe 'when validating field changes' do
      context 'when the contract is provisional' do
        let(:contract) { create(:commercial_contract, status: :provisional) }

        it 'allows editing fields that are editable when provisional' do
          contract.status = :confirmed
          expect(contract).to be_valid
        end

        it 'prevents editing fields that are never editable' do
          contract.product = create(:commercial_product)
          expect(contract).not_to be_valid
          expect(contract.errors[:product_id]).to include('cannot be changed once the contract is in its current state')
        end
      end

      context 'when the contract has no invoiced licences' do
        let(:contract) { create(:commercial_contract) }

        it 'allows editing fields that are editable before invoicing' do
          contract.start_date = contract.start_date + 1.day
          expect(contract).to be_valid
        end
      end

      context 'when the contract has invoiced licences' do
        let(:contract) { create(:commercial_contract, agreed_school_price: 100) }

        before do
          create(:commercial_licence, contract:, status: :invoiced)
        end

        it 'prevents editing fields that become locked after invoicing' do
          contract.agreed_school_price = contract.agreed_school_price + 1
          expect(contract).not_to be_valid
          expect(contract.errors[:agreed_school_price]).to include('cannot be changed once the contract is in its current state')
        end
      end

      context 'when creating' do
        it 'allows setting any field' do
          new_contract = build(:commercial_contract)
          expect(new_contract).to be_valid
        end
      end
    end
  end

  describe '#status_colour' do
    it { expect(create(:commercial_contract, status: :provisional).status_colour).to eq(:warning) }
    it { expect(create(:commercial_contract, status: :confirmed).status_colour).to eq(:success) }
  end

  describe '#editable_fields' do
    subject(:contract) { create(:commercial_contract, status: :provisional) }

    it 'has the expected fields' do
      expect(contract.editable_attributes).to contain_exactly(:agreed_school_price, :comments, :end_date, :name, :number_of_schools, :purchase_order_number, :start_date, :status, :updated_by_id)
    end

    context 'when confirmed' do
      subject(:contract) { create(:commercial_contract, status: :confirmed) }

      it 'has the expected fields' do
        expect(contract.editable_attributes).to contain_exactly(:agreed_school_price, :comments, :end_date, :name, :number_of_schools, :purchase_order_number, :start_date, :updated_by_id)
      end
    end

    context 'with invoiced licences' do
      before do
        create(:commercial_licence, contract:, status: :invoiced)
      end

      it 'has the expected fields' do
        expect(contract.editable_attributes).to contain_exactly(:comments, :name, :number_of_schools, :purchase_order_number, :status, :updated_by_id)
      end
    end
  end

  describe '#as_renewal' do
    subject(:renewed) { described_class.as_renewal(original) }

    let(:original) do
      create(:commercial_contract,
             agreed_school_price: 450.0,
             invoice_terms: :full,
             licence_period: :custom,
             licence_years: 2.0,
             number_of_schools: 15)
    end

    it 'correctly populates the defaults' do
      expect(renewed).to have_attributes(
        agreed_school_price: original.agreed_school_price,
        comments: "Renewed from #{original.name}",
        contract_holder: original.contract_holder,
        invoice_terms: original.invoice_terms,
        licence_period: original.licence_period,
        licence_years: original.licence_years,
        number_of_schools: original.number_of_schools,
        product: original.product,
        start_date: original.end_date + 1.day,
        end_date: original.end_date.next_year
      )
    end
  end
end
