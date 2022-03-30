require 'rails_helper'

describe 'school group meter reports', type: :system do

  let(:admin)                   { create(:admin) }
  let(:school_group)            { create(:school_group, name: 'Big Group') }
  let(:school)                  { create(:school, school_group: school_group) }

  let!(:meter)            { create(:electricity_meter, school: school) }
  let!(:meter_inactive)   { create(:electricity_meter, school: school, active: false) }

  before(:each) do
    sign_in(admin)
    visit admin_reports_path
  end

  context 'when on index page' do

    before :each do
      click_on "School group meter reports"
    end

    it 'displays the reports index' do
      expect(page).to have_content("School group meter data reports")
      expect(page).to have_content(school_group.name)
      expect(page).to have_link("Meter Report")
      expect(page).to have_link("Download CSV")
      expect(page).to have_link("Download meter collections")
    end

    it 'downloads csv' do
      click_on "Download CSV"
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /#{school_group.name.parameterize}-meter-report.csv$/
      expect(page.source).to have_content(school.name)
      expect(page.source).to have_content(meter.mpan_mprn)
    end
  end

  context 'when on school group meter report page' do

    before :each do
      click_on "School group meter reports"
      click_on "Meter Report"
    end

    it 'links to downloads and all meters' do
      expect(page).to have_content("#{school_group.name} meter report")
      expect(page).to have_link("Download CSV")
      expect(page).to have_link("Download meter collections")
    end

    it 'only shows active meters' do
      expect(page).to have_content(meter.mpan_mprn)
      expect(page).not_to have_content(meter_inactive.mpan_mprn)
      expect(page).to have_link("Show all meters")
    end

    it 'links to page including inactive meters' do
      click_on "Show all meters"
      expect(page).to have_content("#{school_group.name} meter report")
      expect(page).to have_content(meter.mpan_mprn)
      expect(page).to have_content(meter_inactive.mpan_mprn)
      expect(page).not_to have_link("Show all meters")
    end

    it 'downloads csv' do
      click_on "Download CSV"
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /#{school_group.name.parameterize}-meter-report.csv$/
      expect(page.source).to have_content(school.name)
      expect(page.source).to have_content(meter.mpan_mprn)
    end
  end
end
