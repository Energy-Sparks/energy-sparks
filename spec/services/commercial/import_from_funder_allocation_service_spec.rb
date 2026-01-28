require 'rails_helper'

describe Commercial::ImportFromFunderAllocationService do
  subject!(:service) { described_class.new(product: create(:commercial_product, :default_product), import_user: create(:admin)) }

  let(:start_date) { Date.new(2025, 9, 1) }
  let(:end_date) { Date.new(2026, 8, 31) }

  describe '#import' do
    context 'with Funder contracts' do
      context 'when school not found' do
        it { expect { service.import('Funder', 'Unknown school') }.not_to change(Commercial::Contract, :count) }
      end

      context 'when school is found' do
        let!(:funder) { create(:funder) }
        let!(:school) { create(:school, :with_school_grouping, funder:) }

        ['', nil].each do |funder_name|
          context "when funder is #{funder_name}" do
            before do
              service.import('', school.name)
            end

            it { expect(school.reload.funder).to be_nil }
            it { expect(Commercial::Contract.count).to be(0) }
          end
        end

        context 'with ignored funder' do
          let!(:funder) { create(:funder, name: 'Pending data') }

          before do
            service.import(funder.name, school.name)
          end

          it { expect(school.reload.funder).to eql(funder) }
          it { expect(Commercial::Contract.count).to be(0) }
        end

        context 'with no existing contract' do
          before do
            service.import(funder.name, school.name)
          end

          it 'creates a contract' do
            expect(Commercial::Contract.first).to have_attributes(
              product: Commercial::Product.default_product,
              contract_holder: funder,
              start_date:,
              end_date:,
              comments: "Imported on #{Time.zone.today}",
              status: 'confirmed',
              agreed_school_price: nil,
              number_of_schools: 1,
              created_by: service.import_user,
              updated_by: service.import_user
            )
          end

          it 'creates a licence' do
            expect(Commercial::Licence.first).to have_attributes(
              contract: funder.contracts.first,
              school:,
              start_date:,
              end_date:,
              status: 'confirmed',
              created_by: service.import_user,
              updated_by: service.import_user
            )
          end

          it 'updates the school' do
            expect(school.reload).to have_attributes(
              funder:,
              default_contract_holder: school.organisation_group
            )
          end
        end

        context 'with an existing matching contract' do
          subject!(:contract) { create(:commercial_contract, contract_holder: funder, product: service.product, start_date:, end_date:, created_by: create(:admin)) }

          let!(:licence) { create(:commercial_licence, contract:, school:, start_date:, end_date:, created_by: create(:admin)) }

          before do
            service.import(funder.name, school.name)
          end

          it 'updates the contract' do
            user = contract.created_by
            expect(contract.reload).to have_attributes(
              product: Commercial::Product.default_product,
              contract_holder: funder,
              start_date:,
              end_date:,
              comments: "Imported on #{Time.zone.today}",
              status: 'confirmed',
              agreed_school_price: nil,
              number_of_schools: 1,
              created_by: user,
              updated_by: service.import_user
            )
          end

          it 'updates the licence' do
            user = licence.created_by
            expect(licence.reload).to have_attributes(
              contract:,
              school:,
              start_date:,
              end_date:,
              status: 'confirmed',
              created_by: user,
              updated_by: service.import_user
            )
          end
        end

        context 'when contract has different dates' do
          let!(:contract) { create(:commercial_contract, contract_holder: funder, product: Commercial::Product.default_product) }

          it { expect { service.import(funder.name, school.name) }.to change(Commercial::Contract, :count).from(1).to(2) }
        end
      end
    end

    context 'with School self funding' do
      let!(:funder) { create(:funder, name: 'School self funding') }
      let!(:school) { create(:school, :with_school_grouping, funder:) }

      context 'with no existing contract' do
        before do
          service.import(funder.name, school.name)
        end

        it 'creates a contract' do
          expect(Commercial::Contract.first).to have_attributes(
            product: service.product,
            contract_holder: school,
            start_date:,
            end_date:,
            comments: "Imported on #{Time.zone.today}",
            status: 'confirmed',
            agreed_school_price: nil,
            number_of_schools: 1,
            created_by: service.import_user,
            updated_by: service.import_user
          )
        end

        it 'creates a licence' do
          expect(Commercial::Licence.first).to have_attributes(
            contract: school.contracts.first,
            school:,
            start_date:,
            end_date:,
            status: 'confirmed',
            created_by: service.import_user,
            updated_by: service.import_user
          )
        end

        it 'updates the school' do
          expect(school.reload).to have_attributes(
            funder:,
            default_contract_holder: school
          )
        end
      end

      context 'with an existing matching contract' do
        subject!(:contract) { create(:commercial_contract, contract_holder: school, product: service.product, start_date:, end_date:, created_by: create(:admin)) }

        let!(:licence) { create(:commercial_licence, contract:, school:, start_date:, end_date:, created_by: create(:admin)) }

        before do
          service.import(funder.name, school.name)
        end

        it 'updates the contract' do
          user = contract.created_by
          expect(contract.reload).to have_attributes(
            product: service.product,
            contract_holder: school,
            start_date:,
            end_date:,
            comments: "Imported on #{Time.zone.today}",
            status: 'confirmed',
            agreed_school_price: nil,
            number_of_schools: 1,
            created_by: user,
            updated_by: service.import_user
          )
        end

        it 'updates the licence' do
          user = licence.created_by
          expect(licence.reload).to have_attributes(
            contract:,
            school:,
            start_date:,
            end_date:,
            status: 'confirmed',
            created_by: user,
            updated_by: service.import_user
          )
        end
      end
    end

    context 'with MAT Funding' do
      let!(:funder) { create(:funder, name: 'MAT funding') }
      let!(:school) { create(:school, :with_school_grouping, funder:) }

      context 'with no existing contract' do
        before do
          service.import(funder.name, school.name)
        end

        it 'creates a contract' do
          expect(Commercial::Contract.first).to have_attributes(
            product: service.product,
            contract_holder: school.organisation_group,
            start_date:,
            end_date:,
            comments: "Imported on #{Time.zone.today}",
            status: 'confirmed',
            agreed_school_price: nil,
            number_of_schools: 1,
            created_by: service.import_user,
            updated_by: service.import_user
          )
        end

        it 'creates a licence' do
          expect(Commercial::Licence.first).to have_attributes(
            contract: school.organisation_group.contracts.first,
            school:,
            start_date:,
            end_date:,
            status: 'confirmed',
            created_by: service.import_user,
            updated_by: service.import_user
          )
        end

        it 'updates the school' do
          expect(school.reload).to have_attributes(
            funder:,
            default_contract_holder: school.organisation_group
          )
        end
      end

      context 'with an existing matching contract' do
        subject!(:contract) { create(:commercial_contract, contract_holder: school.organisation_group, product: service.product, start_date:, end_date:, created_by: create(:admin)) }

        let!(:licence) { create(:commercial_licence, contract:, school:, start_date:, end_date:, created_by: create(:admin)) }

        before do
          service.import(funder.name, school.name)
        end

        it 'updates the contract' do
          user = contract.created_by
          expect(contract.reload).to have_attributes(
            product: service.product,
            contract_holder: school.organisation_group,
            start_date:,
            end_date:,
            comments: "Imported on #{Time.zone.today}",
            status: 'confirmed',
            agreed_school_price: nil,
            number_of_schools: 1,
            created_by: user,
            updated_by: service.import_user
          )
        end

        it 'updates the licence' do
          user = licence.created_by
          expect(licence.reload).to have_attributes(
            contract:,
            school:,
            start_date:,
            end_date:,
            status: 'confirmed',
            created_by: user,
            updated_by: service.import_user
          )
        end
      end
    end
  end
end
