require 'rails_helper'

describe 'manage licences' do
  let(:user) { create(:admin) }
  let!(:school) { create(:school, :with_school_group) }

  before do
    sign_in(user)
    visit admin_path
  end

  context 'when adding a new licence' do
    let!(:contract) { create(:commercial_contract)}

    before do
      click_on 'Contracts'
      click_on(contract.name)
      click_on('New licence')
    end

    context 'with valid data', :js do
      before do
        select 'Confirmed', from: 'Status'
        set_date('#licence_start_date', '01/01/2026')
        set_date('#licence_end_date', '31/12/2026')
        fill_in 'Invoice reference', with: 'INV-001'
        click_on 'Save'
      end

      it 'creates the model' do
        expect(page).to have_content('Licence has been created')
        expect(Commercial::Licence.last).to have_attributes(
          contract:,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          status: 'confirmed',
          invoice_reference: 'INV-001',
          created_by: user
        )
      end
    end

    context 'with invalid data' do
      it { expect { click_on 'Save' }.not_to change(Commercial::Contract, :count) }

      it 'displays errors' do
        click_on 'Save'
        expect(page).to have_content("Start date can't be blank")
      end
    end
  end

  context 'when updating an existing licence' do
    let!(:licence) { create(:commercial_licence) }

    before do
      click_on 'Contracts'
      click_on(licence.contract.name)
      within('#licences') do
        click_on('Edit')
      end
    end

    it { expect(page).to have_content(licence.contract.name) }

    context 'with valid data', :js do
      before do
        select 'Pending invoice', from: 'Status'
        set_date('#licence_start_date', '01/01/2026')
        set_date('#licence_end_date', '31/12/2026')
        fill_in 'Invoice reference', with: 'INV-001'
        click_on 'Save'
      end

      it 'updates the model' do
        expect(page).to have_content('Licence has been updated')
        expect(licence.reload).to have_attributes(
          contract: licence.contract,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          status: 'pending_invoice',
          invoice_reference: 'INV-001',
          created_by: licence.created_by,
          updated_by: user
        )
      end
    end
  end

  context 'when deleting a contract' do
    let!(:licence) { create(:commercial_licence) }

    before do
      click_on 'Licences'
    end

    it { expect { click_on 'Delete' }.to change(Commercial::Licence, :count).by(-1) }
  end

  context 'when viewing a licence' do
    let!(:licence) { create(:commercial_licence) }

    before do
      click_on 'Licences'
      click_on "##{licence.id}"
    end

    it { expect(page).to have_css('#metadata') }

    it { expect(page).to have_content(licence.status.to_s.humanize) }
    it { expect(page).to have_content(licence.school.name) }
    it { expect(page).to have_content(licence.contract.name) }
    it { expect(page).to have_content(licence.contract.product.name) }
    it { expect(page).to have_content(licence.start_date.iso8601) }
    it { expect(page).to have_content(licence.end_date.iso8601) }
  end
end
