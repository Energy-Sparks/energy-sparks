require 'rails_helper'

describe 'manage licences' do
  let(:user) { create(:admin) }
  let!(:school) { create(:school, :with_school_group) }

  before do
    sign_in(user)
    visit admin_path
  end

  context 'when adding a new licence' do
    let!(:contract) { create(:commercial_contract) }
    let!(:school) { create(:school, :with_school_group) }

    before do
      visit new_admin_commercial_licence_path
    end

    context 'with valid data', :js do
      before do
        select contract.name, from: 'Contract'
        select school.name, from: 'School'
        select 'Confirmed', from: 'Status'
        set_date('#licence_start_date', '01/01/2026')
        set_date('#licence_end_date', '31/12/2026')
        fill_in 'Invoice reference', with: 'INV-001'
        fill_in 'School specific price', with: '250.0'
        fill_in 'Comments', with: 'my comments'
        click_on 'Save'
      end

      it 'creates the licence' do
        expect(page).to have_content('Licence has been created')
        expect(Commercial::Licence.last).to have_attributes(
          contract:,
          school:,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          status: 'confirmed',
          invoice_reference: 'INV-001',
          school_specific_price: 250.0,
          comments: 'my comments',
          created_by: user
        )
      end
    end

    context 'with no dates' do
      before do
        select contract.name, from: 'Contract'
        select school.name, from: 'School'
        click_on 'Save'
      end

      it 'creates the licence' do
        expect(page).to have_content('Licence has been created')
        expect(Commercial::Licence.last).to have_attributes(
          contract:,
          school:,
          start_date: Time.zone.today,
          end_date: contract.end_date,
          created_by: user
        )
      end
    end
  end

  context 'when adding a new licence for a contract' do
    let!(:contract) { create(:commercial_contract) }

    before do
      click_on 'Contracts'
      click_on(contract.name)
      click_on('New licence')
    end

    it { expect(page).to have_content("Create a new licence under the #{contract.name} contract.")}

    context 'with valid data', :js do
      before do
        select 'Confirmed', from: 'Status'
        select school.name, from: 'School'
        set_date('#licence_start_date', '01/01/2026')
        set_date('#licence_end_date', '31/12/2026')
        fill_in 'Invoice reference', with: 'INV-001'
        fill_in 'School specific price', with: '250.0'
        fill_in 'Comments', with: 'my comments'
        click_on 'Save'
      end

      it 'creates the model' do
        expect(page).to have_content('Licence has been created')
        expect(Commercial::Licence.last).to have_attributes(
          contract:,
          school:,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          status: 'confirmed',
          invoice_reference: 'INV-001',
          school_specific_price: 250.0,
          comments: 'my comments',
          created_by: user
        )
      end
    end

    context 'with no dates' do
      before do
        select school.name, from: 'School'
        click_on 'Save'
      end

      it 'creates the licence' do
        expect(page).to have_content('Licence has been created')
        expect(Commercial::Licence.last).to have_attributes(
          contract:,
          school:,
          start_date: Time.zone.today,
          end_date: contract.end_date,
          created_by: user
        )
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
    it { expect(page).to have_content("Update the licence for #{licence.school.name} under the #{licence.contract.name} contract.")}

    context 'when dates may change' do
      let!(:school) { create(:school, :with_school_group, data_enabled: false) }
      let!(:contract) { create(:commercial_contract, licence_period: :custom) }
      let!(:licence) { create(:commercial_licence, contract:, school:) }

      it 'includes a warning' do
        expect(page).to have_content('Changes made here will be overwritten')
      end
    end

    context 'with valid data', :js do
      before do
        select 'Pending invoice', from: 'Status'
        set_date('#licence_start_date', '01/01/2026')
        set_date('#licence_end_date', '31/12/2026')
        fill_in 'Invoice reference', with: 'INV-001'
        fill_in 'School specific price', with: '250.0'
        fill_in 'Comments', with: 'my comments'
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
          school_specific_price: 250.0,
          comments: 'my comments',
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
    it { expect(page).to have_content(licence.comments) }
  end

  context 'when viewing licence index' do
    let!(:school_group) { create(:school_group) }
    let!(:school) { create(:school, :with_school_grouping, group: school_group) }

    let!(:expiring_in_a_week) { create(:commercial_licence, end_date: Time.zone.today + 7, school: school) }
    let!(:expiring_in_a_month) { create(:commercial_licence, created_at: Time.zone.yesterday, updated_at: Time.zone.today, end_date: Time.zone.today + 30) }
    let!(:expired) { create(:commercial_licence, :historical) }

    before { click_on('Licences') }

    it { expect(page).to have_content('Expiring') }

    it 'shows expiring licences' do
      within('#expiring') do
        expect(page).to have_link(href: admin_commercial_licence_path(expiring_in_a_week.id))
        expect(page).to have_link(href: admin_commercial_licence_path(expiring_in_a_month.id))
      end
    end

    it 'shows recent licences' do
      within('#recent') do
        expect(page).to have_link(href: admin_commercial_licence_path(expiring_in_a_week.id))
        expect(page).to have_link(href: admin_commercial_licence_path(expiring_in_a_month.id))
      end
    end

    it 'shows expired licences' do
      within('#recently-expired') do
        expect(page).to have_link(href: admin_commercial_licence_path(expired.id))
      end
    end

    it 'shows recently updated licences' do
      within('#recently-updated') do
        expect(page).to have_link(href: admin_commercial_licence_path(expiring_in_a_month.id))
      end
    end

    context 'when filtering by school group' do
      before do
        within('#expiring') do
          select(school_group.name, from: 'School group')
          fill_in(:filters_expiry_date, with: (Time.zone.today + 30.days).iso8601)
          click_on('Filter')
        end
      end

      it 'shows the filtered expiring licences' do
        within('#expiring') do
          expect(page).to have_link(href: admin_commercial_licence_path(expiring_in_a_week.id))
          expect(page).not_to have_link(href: admin_commercial_licence_path(expiring_in_a_month.id))
        end
      end
    end

    context 'when filtering by just date' do
      before do
        within('#expiring') do
          fill_in(:filters_expiry_date, with: (Time.zone.today + 10.days).iso8601)
          click_on('Filter')
        end
      end

      it 'shows the filtered expiring licences' do
        within('#expiring') do
          expect(page).to have_link(href: admin_commercial_licence_path(expiring_in_a_week.id))
          expect(page).not_to have_link(href: admin_commercial_licence_path(expiring_in_a_month.id))
        end
      end
    end
  end
end
