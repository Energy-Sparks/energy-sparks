# frozen_string_literal: true

require 'rails_helper'

shared_examples 'a licence list filtered by date' do
  let(:filter_date) { nil }

  it { expect(page).to have_field(:date) }

  context 'when applying the filter', :js do
    before do
      set_date('#filters_date', filter_date)
      click_on 'Filter'
    end

    it 'filters the view' do
      within('#licences-table') do
        expect(page).to have_no_link(href: admin_commercial_licence_path(filtered_licence.id))
      end
    end
  end
end

shared_examples 'a licence list filtered by school group' do
  it { expect(page).to have_field('School group') }

  context 'when applying the filter' do
    before do
      select(filter_group.name, from: 'School group')
      click_on 'Filter'
    end

    it 'filters the view' do
      within('#licences-table') do
        expect(page).to have_no_link(href: admin_commercial_licence_path(filtered_licence.id))
      end
    end
  end
end

describe 'manage licences' do
  let(:user) { create(:admin) }
  let!(:school) { create(:school, :with_school_group) }

  before do
    sign_in(user)
    visit admin_commercial_path
  end

  context 'when adding a new licence' do
    let!(:contract) { create(:commercial_contract) }
    let!(:school) { create(:school, :with_school_group) }

    before do
      visit new_admin_commercial_licence_path
    end

    it { expect(page).to have_text('Leave the following fields blank ') }

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
        expect(page).to have_text('Licence has been created')
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

    context 'when school has an existing licence that overlap', :js do
      before do
        create(:commercial_licence, school:, start_date: Date.new(2026, 1, 1), end_date: Date.new(2026, 12, 31))
        select contract.name, from: 'Contract'
        select school.name, from: 'School'
        select 'Confirmed', from: 'Status'
        set_date('#licence_start_date', '01/01/2026')
        set_date('#licence_end_date', '31/12/2026')
        click_on 'Save'
      end

      it { expect(page).to have_text('Licence has been created. But this school now has overlapping licences') }
    end

    context 'with no dates' do
      before do
        select contract.name, from: 'Contract'
        select school.name, from: 'School'
        click_on 'Save'
      end

      it 'creates the licence' do
        expect(page).to have_text('Licence has been created')
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
      click_on 'All Contracts'
      click_on(contract.name)
      click_on('Add New Licence')
    end

    it { expect(page).to have_text('Leave the following fields blank to automatically populate the licence') }
    it { expect(page).to have_text("Create a new licence under the #{contract.name} contract.") }

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
        expect(page).to have_text('Licence has been created')
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

      context 'when the contract is confirmed and school is data enabled' do
        let!(:contract) { create(:commercial_contract, status: :confirmed) }

        it 'creates the model' do
          expect(page).to have_text('Licence has been created')
          expect(Commercial::Licence.last).to have_attributes(
            contract:,
            school:,
            start_date: Date.new(2026, 1, 1),
            end_date: Date.new(2026, 12, 31),
            status: 'pending_invoice',
            invoice_reference: 'INV-001',
            school_specific_price: 250.0,
            comments: 'my comments',
            created_by: user
          )
        end
      end
    end

    context 'with no dates' do
      before do
        select school.name, from: 'School'
        click_on 'Save'
      end

      it 'creates the licence' do
        expect(page).to have_text('Licence has been created')
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
      click_on 'All Contracts'
      click_on(licence.contract.name)
      within('#licences') do
        click_on('Edit')
      end
    end

    it { expect(page).to have_text(licence.contract.name) }

    it {
      expect(page).to have_text(
        "Update the licence for #{licence.school.name} under the #{licence.contract.name} contract."
      )
    }

    context 'when dates may change' do
      let!(:school) { create(:school, :with_school_group, data_enabled: false) }
      let!(:contract) { create(:commercial_contract, :custom) }
      let!(:licence) { create(:commercial_licence, contract:, school:) }

      it 'includes a warning' do
        expect(page).to have_text('Any changes made here will then be overwritten.')
      end
    end

    context 'with valid data', :js do
      before do
        select 'Confirmed', from: 'Status'
        set_date('#licence_start_date', '01/01/2026')
        set_date('#licence_end_date', '31/12/2026')
        fill_in 'Invoice reference', with: 'INV-001'
        fill_in 'School specific price', with: '250.0'
        fill_in 'Comments', with: 'my comments'
        click_on 'Save'
      end

      it 'updates the model' do
        expect(page).to have_text('Licence has been updated')
        expect(licence.reload).to have_attributes(
          contract: licence.contract,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          status: 'confirmed',
          invoice_reference: 'INV-001',
          school_specific_price: 250.0,
          comments: 'my comments',
          created_by: licence.created_by,
          updated_by: user
        )
      end

      context 'with confirmed contract for data enabled school' do
        let!(:licence) do
          create(:commercial_licence,
                 contract: create(:commercial_contract, status: :confirmed),
                 school: create(:school, data_enabled: true))
        end

        it 'updates the model' do
          expect(page).to have_text('Licence has been updated')
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

    context 'when school has an existing licence that overlap', :js do
      before do
        create(:commercial_licence,
               school: licence.school,
               start_date: Date.new(2026, 1, 1),
               end_date: Date.new(2026, 12, 31))
        select 'Pending invoice', from: 'Status'
        set_date('#licence_start_date', '01/01/2026')
        set_date('#licence_end_date', '31/12/2026')
        click_on 'Save'
      end

      it { expect(page).to have_text('Licence has been updated. But this school now has overlapping licences') }
    end

    context 'when licence is invoiced' do
      let!(:licence) { create(:commercial_licence, status: :invoiced) }

      it { expect(page).to have_text('This licence has been invoiced. Only limited changes can now be made') }

      it { expect(page).to have_no_field('School specific price') }

      it { expect(page).to have_no_field('Status') }
      it { expect(page).to have_no_field('Start date') }
      it { expect(page).to have_no_field('End date') }
    end
  end

  context 'when deleting a licence' do
    before do
      create(:commercial_licence)
      visit admin_commercial_licences_path
    end

    it { expect { click_on 'Delete' }.to change(Commercial::Licence, :count).by(-1) }
  end

  context 'when viewing a licence' do
    let!(:licence) { create(:commercial_licence) }

    before do
      visit admin_commercial_licences_path
      click_on "##{licence.id}"
    end

    it { expect(page).to have_css('#metadata') }

    it { expect(page).to have_text(licence.status.to_s.humanize) }
    it { expect(page).to have_text(licence.school.name) }
    it { expect(page).to have_text(licence.contract.name) }
    it { expect(page).to have_text(licence.contract.product.name) }
    it { expect(page).to have_text(licence.start_date.to_fs(:es_short)) }
    it { expect(page).to have_text(licence.end_date.to_fs(:es_short)) }
    it { expect(page).to have_text(licence.comments) }
  end

  context 'when viewing licence lists' do
    let!(:school_group) { create(:school_group) }
    # this is used in the shared examples, must be created before page load
    # rubocop:disable RSpec/LetSetup
    let!(:filter_group) { create(:school_group, :with_active_schools) }
    # rubocop:enable RSpec/LetSetup
    #
    let!(:school) { create(:school, :with_school_grouping, group: school_group) }

    context 'with current' do
      let!(:licence) { create(:commercial_licence, school:) }

      before { click_on 'Current Licences' }

      it { expect(page).to have_no_field(:date) }
      it { expect(page).to have_no_field(:school_group_id) }

      it 'shows the licence' do
        within('#licences-table') do
          expect(page).to have_link(href: admin_commercial_licence_path(licence.id))
        end
      end
    end

    context 'with expired' do
      let!(:licence) { create(:commercial_licence, :expired, school:) }

      before { click_on 'Expired Licences' }

      it 'shows the licence' do
        within('#licences-table') do
          expect(page).to have_link(href: admin_commercial_licence_path(licence.id))
        end
      end

      it_behaves_like 'a licence list filtered by date' do
        let(:filter_date) { (licence.end_date - 1).strftime('%d/%m/%Y') }
        let(:filtered_licence) { licence }
      end

      it_behaves_like 'a licence list filtered by school group' do
        let(:filtered_licence) { licence }
      end
    end

    context 'with expiring' do
      let!(:licence) { create(:commercial_licence, end_date: Time.zone.today + 7, school:) }

      before { click_on 'Expiring Licences' }

      it 'shows the licence' do
        within('#licences-table') do
          expect(page).to have_link(href: admin_commercial_licence_path(licence.id))
        end
      end

      it_behaves_like 'a licence list filtered by date' do
        let(:filter_date) { Time.zone.yesterday.strftime('%d/%m/%Y') }
        let(:filtered_licence) { licence }
      end

      it_behaves_like 'a licence list filtered by school group' do
        let(:filtered_licence) { licence }
      end
    end

    context 'with recent' do
      let!(:licence) { create(:commercial_licence, school:) }

      before { click_on 'Recently Added Licences' }

      it 'shows the licence' do
        within('#licences-table') do
          expect(page).to have_link(href: admin_commercial_licence_path(licence.id))
        end
      end

      it_behaves_like 'a licence list filtered by date' do
        let(:filter_date) { Time.zone.tomorrow.strftime('%d/%m/%Y') }
        let(:filtered_licence) { licence }
      end

      it_behaves_like 'a licence list filtered by school group' do
        let(:filtered_licence) { licence }
      end
    end

    context 'with all' do
      let!(:licence) { create(:commercial_licence, school:) }

      before { click_on 'All Licences' }

      it { expect(page).to have_no_field(:date) }

      it 'shows the licence' do
        within('#licences-table') do
          expect(page).to have_link(href: admin_commercial_licence_path(licence.id))
        end
      end
    end

    context 'with overlapping' do
      let!(:licence_one) do
        create(:commercial_licence, school:, start_date: Date.new(2024, 1, 1), end_date: Date.new(2024, 12, 31))
      end

      let!(:licence_two) do
        create(:commercial_licence,
               school: licence_one.school,
               start_date: Date.new(2024, 6, 1),
               end_date: Date.new(2025, 12, 31))
      end

      before do
        click_on 'Overlapping Licences'
      end

      it 'shows the contract' do
        within('#licences-table') do
          expect(page).to have_link(href: admin_commercial_licence_path(licence_one.id))
          expect(page).to have_link(href: admin_commercial_licence_path(licence_two.id))
        end
      end
    end
  end

  context 'when viewing unlicensed schools' do
    let!(:school) do
      school = create(:school, :with_trust)
      school.update(diocese: create(:school_group, :diocese))
      school
    end

    before do
      calendar = create(:national_calendar, title: 'England and Wales')
      academic_year = create(:academic_year, calendar:)
      create(:academic_year,
             calendar:,
             start_date: academic_year.end_date + 1.day,
             end_date: academic_year.end_date + 1.year)
      click_on 'Unlicensed schools'
    end

    it { expect(page).to have_css('div.commercial-unlicensed-schools') }
    it { expect(page).to have_text(school.name) }
  end
end
