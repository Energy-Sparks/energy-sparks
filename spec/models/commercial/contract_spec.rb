# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Contract do
  include ActiveJob::TestHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    context 'when validating names' do
      subject { build(:commercial_contract, :with_school) }

      it { is_expected.to validate_uniqueness_of(:name) }
    end

    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_numericality_of(:number_of_schools).is_greater_than(0) }

    it_behaves_like 'a temporal ranged model'
    it_behaves_like 'a date ranged model'
    it_behaves_like 'has a contract holder'

    it 'validates invoice terms' do
      expect(build(:commercial_contract, licence_period: :contract, invoice_terms: :full)).to be_valid
      expect(build(:commercial_contract, licence_period: :contract, invoice_terms: :pro_rata)).to be_valid
      expect(build(:commercial_contract, licence_period: :custom, invoice_terms: :full)).to be_valid
      expect(build(:commercial_contract, licence_period: :custom, invoice_terms: :pro_rata)).not_to be_valid
    end

    context 'when destroying' do
      let!(:contract) { create(:commercial_contract) }

      it 'allows contracts to be deleted' do
        expect { contract.destroy }.to change(described_class, :count).by(-1)
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

      context 'with an invoice' do
        before do
          create(:commercial_invoice, contract:)
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
          expect { contract.destroy }.to change(described_class, :count).by(-1)
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
          contract.contract_holder = create(:funder)
          expect(contract).not_to be_valid
          expect(contract.errors[:contract_holder_id]).to include(
            'cannot be changed once the contract is in its current state'
          )
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
          expect(contract.errors[:agreed_school_price]).to include(
            'cannot be changed once the contract is in its current state'
          )
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
    context 'with standard contract' do
      subject(:contract) { create(:commercial_contract, status: :provisional) }

      it 'has the expected fields' do
        expect(contract.editable_attributes).to contain_exactly(:agreed_school_price, :comments, :end_date,
                                                                :invoice_terms,
                                                                :name, :number_of_schools,
                                                                :product_id, :purchase_order_number,
                                                                :start_date, :status, :updated_by_id,
                                                                :xero_account_code_id)
      end

      context 'when confirmed' do
        subject(:contract) { create(:commercial_contract, status: :confirmed) }

        it 'has the expected fields' do
          expect(contract.editable_attributes).to contain_exactly(:agreed_school_price, :comments, :end_date,
                                                                  :invoice_terms,
                                                                  :name, :number_of_schools,
                                                                  :product_id, :purchase_order_number,
                                                                  :start_date, :updated_by_id, :xero_account_code_id)
        end
      end

      context 'with invoiced licences' do
        before do
          create(:commercial_licence, contract:, status: :invoiced)
        end

        it 'has the expected fields' do
          expect(contract.editable_attributes).to contain_exactly(:comments, :name, :number_of_schools,
                                                                  :purchase_order_number, :status, :updated_by_id,
                                                                  :xero_account_code_id)
        end
      end
    end

    context 'with custom contract' do
      subject(:contract) { create(:commercial_contract, :custom, status: :provisional) }

      it 'has the expected fields' do
        expect(contract.editable_attributes).to contain_exactly(:agreed_school_price, :comments, :end_date,
                                                                :licence_years, :name, :number_of_schools,
                                                                :product_id, :purchase_order_number,
                                                                :start_date, :status, :updated_by_id,
                                                                :xero_account_code_id)
      end

      context 'when confirmed' do
        subject(:contract) { create(:commercial_contract, :custom, status: :confirmed) }

        it 'has the expected fields' do
          expect(contract.editable_attributes).to contain_exactly(:agreed_school_price, :comments, :end_date,
                                                                  :licence_years, :name, :number_of_schools,
                                                                  :product_id, :purchase_order_number,
                                                                  :start_date, :updated_by_id, :xero_account_code_id)
        end
      end

      context 'with invoiced licences' do
        before do
          create(:commercial_licence, contract:, status: :invoiced)
        end

        it 'has the expected fields' do
          expect(contract.editable_attributes).to contain_exactly(:comments, :name, :number_of_schools,
                                                                  :purchase_order_number, :status, :updated_by_id,
                                                                  :xero_account_code_id)
        end
      end
    end
  end

  describe '#as_renewal' do
    context 'when renewing as a custom contract' do
      subject(:renewed) { described_class.as_renewal(original, chosen_type: :custom) }

      let(:original) do
        create(:commercial_contract,
               :custom,
               agreed_school_price: 450.0,
               licence_years: 2.0,
               number_of_schools: 15)
      end

      it 'correctly populates the new contract' do
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

      context 'when switching type' do
        let(:original) do
          create(:commercial_contract,
                 licence_period: :contract,
                 invoice_terms: :pro_rata,
                 agreed_school_price: 450.0,
                 licence_years: 2.0,
                 number_of_schools: 15)
        end

        it 'correctly switches the contract options' do
          expect(renewed).to have_attributes(
            agreed_school_price: original.agreed_school_price,
            comments: "Renewed from #{original.name}",
            contract_holder: original.contract_holder,
            invoice_terms: 'full',
            licence_period: 'custom',
            licence_years: original.licence_years,
            number_of_schools: original.number_of_schools,
            product: original.product,
            start_date: original.end_date + 1.day,
            end_date: original.end_date.next_year
          )
        end
      end
    end

    context 'when renewing as a standard contract' do
      subject(:renewed) { described_class.as_renewal(original, chosen_type: :pro_rata) }

      let(:original) do
        create(:commercial_contract,
               licence_period: :contract,
               invoice_terms: :pro_rata,
               agreed_school_price: 450.0,
               number_of_schools: 15)
      end

      it 'correctly populates the new contract' do
        expect(renewed).to have_attributes(
          agreed_school_price: original.agreed_school_price,
          comments: "Renewed from #{original.name}",
          contract_holder: original.contract_holder,
          invoice_terms: 'pro_rata',
          licence_period: original.licence_period,
          number_of_schools: original.number_of_schools,
          product: original.product,
          start_date: original.end_date + 1.day,
          end_date: original.end_date.next_year
        )
      end

      context 'when the original licence terms were full' do
        let(:original) do
          create(:commercial_contract,
                 licence_period: :contract,
                 invoice_terms: :full,
                 agreed_school_price: 450.0,
                 number_of_schools: 15)
        end

        it 'switches to a pro-rata contract' do
          expect(renewed).to have_attributes(
            agreed_school_price: original.agreed_school_price,
            comments: "Renewed from #{original.name}",
            contract_holder: original.contract_holder,
            invoice_terms: 'pro_rata',
            licence_period: original.licence_period,
            number_of_schools: original.number_of_schools,
            product: original.product,
            start_date: original.end_date + 1.day,
            end_date: original.end_date.next_year
          )
        end
      end

      context 'when switching type' do
        let(:original) do
          create(:commercial_contract,
                 :custom,
                 agreed_school_price: 450.0,
                 licence_years: 2.0,
                 number_of_schools: 15)
        end

        it 'correctly switches the contract options' do
          expect(renewed).to have_attributes(
            agreed_school_price: original.agreed_school_price,
            comments: "Renewed from #{original.name}",
            contract_holder: original.contract_holder,
            invoice_terms: 'pro_rata',
            licence_period: 'contract',
            licence_years: original.licence_years,
            number_of_schools: original.number_of_schools,
            product: original.product,
            start_date: original.end_date + 1.day,
            end_date: original.end_date.next_year
          )
        end
      end
    end
  end

  describe '.over_licensed' do
    let!(:contract) { create(:commercial_contract, number_of_schools: 1) }
    let(:licence_count) { 1 }

    before do
      create_list(:commercial_licence, licence_count, contract:)
    end

    it { expect(described_class.over_licensed).to be_empty }

    context 'with too many licences' do
      let(:licence_count) { 2 }

      it { expect(described_class.over_licensed).to include(contract) }
    end
  end

  describe '.overlapping' do
    let!(:contract_one) do
      create(:commercial_contract, start_date: Date.new(2024, 1, 1), end_date: Date.new(2024, 12, 31))
    end
    let!(:contract_two) do
      create(:commercial_contract,
             contract_holder: contract_one.contract_holder,
             start_date: Date.new(2025, 1, 1),
             end_date: Date.new(2025, 12, 31))
    end

    it { expect(described_class.overlapping).to(be_empty) }

    context 'when there are overlaps for different contract holders' do
      let!(:contract_two) do
        create(:commercial_contract, start_date: Date.new(2024, 6, 1), end_date: Date.new(2025, 12, 31))
      end

      it { expect(described_class.overlapping).to(be_empty) }
    end

    context 'when there are overlaps for same contract holder' do
      let!(:contract_two) do
        create(:commercial_contract, contract_holder: contract_one.contract_holder,
                                     start_date: Date.new(2024, 6, 1), end_date: Date.new(2025, 12, 31))
      end

      it { expect(described_class.overlapping).to(contain_exactly(contract_one, contract_two)) }
    end
  end

  describe '.ordered_by_contract_holder_name' do
    let!(:school_contract) { create(:commercial_contract, contract_holder: create(:school, name: 'XYZ School')) }
    let!(:group_contract) { create(:commercial_contract, contract_holder: create(:school_group, name: 'Big Group')) }
    let!(:funder_contract) { create(:commercial_contract, contract_holder: create(:funder, name: 'ABC, Inc')) }

    it {
      expect(described_class.ordered_by_contract_holder_name).to eq([funder_contract, group_contract, school_contract])
    }
  end

  describe '.current_contract_holder_summaries' do
    subject(:summaries) { described_class.current_contract_holder_summaries }

    shared_examples 'a correctly generated summary' do
      let(:contract_holder_type) { contract_holder.class.name }

      context 'with no current contract' do
        it 'returns nothing' do
          expect(summaries).to be_empty
        end
      end

      context 'with a mixture of visible and data enabled schools' do
        include_context 'with a mixture of contracted schools and onboardings'

        it 'returns expected summary' do
          expect(summaries.first).to eq({
                                          id: contract_holder.id,
                                          name: contract_holder.name,
                                          type: contract_holder_type,
                                          visible_not_data_enabled: 2,
                                          visible_data_enabled: 3,
                                          onboardings: 1,
                                          total: 6
                                        })
        end
      end

      context 'with multiple current contracts' do
        before do
          2.times do
            create(:commercial_licence,
                   contract: create(:commercial_contract, contract_holder:),
                   school: create(:school, data_enabled: false))
          end
          3.times do
            create(:commercial_licence,
                   contract: create(:commercial_contract, contract_holder:),
                   school: create(:school, data_enabled: true))
          end
          create(:school_onboarding, contract: create(:commercial_contract, contract_holder:), school: nil)
        end

        it 'returns expected summary' do
          expect(summaries.first).to eq({
                                          id: contract_holder.id,
                                          name: contract_holder.name,
                                          type: contract_holder_type,
                                          visible_not_data_enabled: 2,
                                          visible_data_enabled: 3,
                                          onboardings: 1,
                                          total: 6
                                        })
        end
      end
    end

    context 'with a Funder' do
      it_behaves_like 'a correctly generated summary' do
        let!(:contract_holder) { create(:funder) } # rubocop:disable RSpec/LetSetup
      end
    end

    context 'with a School Group' do
      it_behaves_like 'a correctly generated summary' do
        let!(:contract_holder) { create(:school_group) } # rubocop:disable RSpec/LetSetup
      end
    end

    context 'with a School' do
      it_behaves_like 'a correctly generated summary' do
        let!(:contract_holder) { create(:school) } # rubocop:disable RSpec/LetSetup
      end
    end
  end

  describe '.with_invoiced_contract_holders' do
    let!(:school_contract) { create(:commercial_contract, contract_holder: create(:school)) }
    let!(:group_contract) { create(:commercial_contract, contract_holder: create(:school_group)) }
    let!(:funder_contract) { create(:commercial_contract, contract_holder: create(:funder, invoiced: true)) }

    before do
      create(:commercial_contract, contract_holder: create(:funder, invoiced: false))
    end

    it 'returns only school, group and invoiced funder contracts' do
      expect(described_class.with_invoiced_contract_holders).to contain_exactly(school_contract, group_contract,
                                                                                funder_contract)
    end
  end

  describe '.pending_invoicing' do
    let!(:funder_contract) { create(:commercial_contract, contract_holder: create(:funder, invoiced: true)) }

    before do
      create(:commercial_licence, status: :confirmed)
      create(:commercial_licence, contract: funder_contract, status: :pending_invoice)

      not_invoiced = create(:commercial_contract, contract_holder: create(:funder, invoiced: false))
      create(:commercial_licence, contract: not_invoiced, status: :pending_invoice)
    end

    it 'returns only contracts with pending invoices' do
      expect(described_class.pending_invoicing).to contain_exactly(funder_contract)
    end
  end

  describe '#candidate_schools' do
    context 'with School' do
      let!(:contract) { create(:commercial_contract, :with_school) }

      it { expect(contract.candidate_schools).to eq([]) }
    end

    context 'with Funder' do
      let!(:school) { create(:school) }
      let!(:contract) { create(:commercial_contract, :with_funder) }

      it { expect(contract.candidate_schools).to eq([school]) }

      context 'with an already licensed school' do
        let!(:school) { create(:school) }

        before do
          create(:commercial_licence, contract:)
        end

        it { expect(contract.candidate_schools).to eq([school]) }
      end
    end

    context 'with SchoolGroup' do
      let!(:school_group) { create(:school_group, :with_active_schools) }
      let!(:contract) { create(:commercial_contract, contract_holder: school_group) }

      it { expect(contract.candidate_schools).to eq(school_group.assigned_schools.by_name) }

      context 'with an already licensed school' do
        let!(:school_group) { create(:school_group) }
        let!(:school) { create(:school, school_group:) }

        before do
          create(:commercial_licence, contract:, school: create(:school, school_group:))
        end

        it { expect(contract.candidate_schools).to eq([school]) }
      end
    end
  end
end
