require 'rails_helper'

describe Commercial::LicenceImporter do
  subject(:service) { described_class.new(import_user:) }

  let!(:contract) { create(:commercial_contract) }
  let!(:import_user) { create(:admin) }
  let!(:school) { create(:school, :with_school_group) }

  let(:start_date) { Date.new(2025, 9, 1) }
  let(:end_date) { Date.new(2026, 8, 31) }

  describe '#import' do
    describe 'when contract doesnt exist' do
      subject(:licence) do
        service.import({
          contract_name: 'Unknown',
          school_group: school.school_group.name,
          licence_holder: school.name,
          start_date:,
          end_date:
        })
      end

      it 'doesnt create a licence' do
        expect { licence }.not_to change(Commercial::Licence, :count)
      end
    end

    describe 'when school cannot be found' do
      subject(:licence) do
        service.import({
          contract_name: contract.name,
          school_group: 'Unknown',
          licence_holder: 'Unknown',
          start_date:,
          end_date:
        })
      end

      it 'doesnt create a licence' do
        expect { licence }.not_to change(Commercial::Licence, :count)
      end
    end

    describe 'when a contract exists' do
      subject(:licence) do
        service.import({
          contract_name: contract.name,
          school_group: school.school_group.name,
          licence_holder: school.name,
          start_date: start_date.iso8601,
          end_date: end_date.iso8601,
          school_specific_price: 650.0,
          status: 'invoiced',
          comments: 'Important notes'
        })
      end

      it 'creates the expected licence' do
        expect(licence).to have_attributes({
          contract:,
          school:,
          start_date:,
          end_date:,
          school_specific_price: 650.0,
          status: 'invoiced',
          comments: 'Important notes',
          created_by: import_user,
          updated_by: import_user
        })
      end

      context 'with duplicate school names' do
        let!(:duplicate) { create(:school, :with_school_group, name: school.name) }

        it 'creates the expected licence' do
          expect(licence).to have_attributes({
            contract:,
            school:,
            start_date:,
            end_date:,
            school_specific_price: 650.0,
            status: 'invoiced',
            comments: 'Important notes',
            created_by: import_user,
            updated_by: import_user
          })
        end
      end

      context 'with an existing licence' do
        let!(:existing_licence) { create(:commercial_licence, contract:, school:, start_date:, end_date:) }

        it 'updates the licence' do
          expect(licence).to have_attributes({
            contract:,
            school:,
            start_date:,
            end_date:,
            school_specific_price: 650.0,
            status: 'invoiced',
            comments: 'Important notes',
            created_by: existing_licence.created_by,
            updated_by: import_user
          })
        end
      end
    end
  end
end
