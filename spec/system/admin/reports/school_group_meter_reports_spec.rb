require 'rails_helper'

describe 'school group meter reports', type: :system do
  let(:admin)                   { create(:admin) }
  let(:school_group)            { create(:school_group, name: 'Big Group') }
  let(:school)                  { create(:school, school_group: school_group) }

  let(:data_source)       { create(:data_source) }
  let!(:meter)            { create(:electricity_meter, school: school, data_source: data_source) }
  let!(:meter_inactive)   { create(:electricity_meter, school: school, active: false, data_source: data_source) }

  before do
    sign_in(admin)
    visit admin_reports_path
  end

  context 'when on index page' do
    before do
      click_on 'School group meter reports'
    end

    it 'displays the reports index' do
      expect(page).to have_content('School group meter data reports')
      expect(page).to have_content(school_group.name)
      expect(page).to have_button('Meter report')
    end

    context 'when clicking on the email meter report link', js: true do
      before do
        click_on 'Meter report'
        accept_alert do
          click_on 'Email meter report'
        end
      end

      it { expect(page).to have_content "Meter report for #{school_group.name} requested to be sent to #{admin.email}" }
      it { expect(page).to have_content 'School group meter data reports' }
    end
  end

  context 'when viewing the "unlinked" school group meter report page' do
    before do
      visit admin_school_group_meter_report_path(school_group)
    end

    it 'links to downloads and all meters' do
      expect(page).to have_content("#{school_group.name} meter report")
      expect(page).to have_button('Meter report')
    end

    it 'only shows active meters' do
      expect(page).to have_content(meter.mpan_mprn)
      expect(page).not_to have_content(meter_inactive.mpan_mprn)
      expect(page).to have_link('Show all meters')
    end

    it 'links to page including inactive meters' do
      click_on 'Show all meters'
      expect(page).to have_content("#{school_group.name} meter report")
      expect(page).to have_content(meter.mpan_mprn)
      expect(page).to have_content(meter_inactive.mpan_mprn)
      expect(page).not_to have_link('Show all meters')
    end
  end
end
