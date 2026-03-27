# frozen_string_literal: true

require 'rails_helper'

describe 'bulk editing contract licences' do
  let(:user) { create(:admin) }

  let!(:contract) { create(:commercial_contract) }
  let!(:licence) { create(:commercial_licence, contract:) }

  let!(:licence_to_be_modified) do
    create(:commercial_licence,
           contract:,
           school_specific_price: 100.0,
           invoice_reference: 'INV-001',
           comments: 'Some comments')
  end

  before do
    sign_in(user)
    visit admin_commercial_contract_path(contract)
    click_on('Manage All Licences')
  end

  it { expect(page).to have_content("#{contract.name} Bulk Licence Editor") }

  def field_name(licence, name)
    "commercial_contract[licences_attributes][#{licence.id}][#{name}]"
  end

  def fill_in_field(licence, field, value)
    fill_in(field_name(licence, field), with: value)
  end

  context 'when deleting a licence', :js do
    before do
      within("#licence-#{licence_to_be_modified.id}-main-row") do
        click_on 'Delete'
      end
    end

    it { expect(page).to have_content('Undo') }

    context 'when the changes are saved' do
      before { click_on 'Save changes' }

      it 'deletes the licence' do
        expect(page).to have_content('Licences updated')
        expect(Commercial::Licence.all).to eq([licence])
      end
    end
  end

  context 'when modifying a licence', :js do
    before do
      fill_in_field(licence_to_be_modified, :school_specific_price, '200.0')
      fill_in_field(licence_to_be_modified, :comments, 'Increased price')
      set_date("#commercial_contract_licences_attributes_#{licence_to_be_modified.id}_start_date", '01/01/2026')
      set_date("#commercial_contract_licences_attributes_#{licence_to_be_modified.id}_end_date", '31/12/2026')
      select('Confirmed', from: field_name(licence_to_be_modified, :status))
      click_on('Save changes')
    end

    it 'updates the licence' do
      expect(page).to have_content('Licences updated')
      expect(licence_to_be_modified.reload).to have_attributes({
                                                                 school_specific_price: 200.0,
                                                                 status: 'confirmed',
                                                                 comments: 'Increased price',
                                                                 start_date: Date.new(2026, 1, 1),
                                                                 end_date: Date.new(2026, 12, 31)
                                                               })
    end
  end

  describe 'when modifying licences for a school group', :js do
    let!(:contract) { create(:commercial_contract, contract_holder: create(:school_group)) }
    let!(:licence) do
      create(:commercial_licence, contract:,
                                  school: create(:school, :with_trust, group: contract.contract_holder))
    end

    context 'when there are additional schools' do
      let!(:additional_school) do
        create(:school, :with_trust, group: contract.contract_holder,
                                     default_contract_holder: contract.contract_holder)
      end

      before { refresh }

      it { expect(page).to have_content('Add schools to contract') }

      it 'lists the school' do
        within("#contract-#{contract.id}-additional-schools-table") do
          expect(page).to have_content(additional_school.name)
        end
      end

      it 'does not show a licence for the school' do
        within("#contract-#{contract.id}-licence-table") do
          expect(page).to have_no_content(additional_school.name)
        end
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when creating a new licence for the school' do
        before do
          click_on 'Add licence'
          # forcing a wait
          within("#contract-#{contract.id}-licence-table") do
            find('tr', text: additional_school.name)
          end
        end

        it 'updates the licence table to include the licence' do
          within("#contract-#{contract.id}-licence-table") do
            expect(page).to have_content(additional_school.name)
          end
          expect(additional_school.reload.licences.count).to eq(1)
        end

        context 'when deleting that licence' do
          before do
            licence = additional_school.licences.reload.last
            within("#licence-#{licence.id}-main-row") do
              click_on 'Delete'
            end
            click_on 'Save changes'
          end

          it 'deletes the licence' do
            expect(page).to have_content('Licences updated')
            expect(additional_school.licences.reload).to be_empty
          end
        end

        context 'when editing that licence' do
          before do
            fill_in_field(additional_school.licences.reload.last, :comments, 'Some comments')
            click_on('Save changes')
          end

          it 'updates the newly added licence' do
            expect(page).to have_content('Licences updated')
            expect(additional_school.licences.reload.last.comments).to eq('Some comments')
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end
end
