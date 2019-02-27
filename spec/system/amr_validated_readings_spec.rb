require 'rails_helper'

RSpec.describe "amr validated readings", :amr_validated_readings, type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school)     { create_active_school(name: school_name)}
  let!(:admin)      { create(:user, role: 'admin')}

  before(:each) do
    sign_in(admin)
    visit root_path
  end

  context 'when a meter has readings' do
    let!(:meter) { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school) }

    it 'allows a download of all CSV data' do
      click_on('Reports')
      click_on('AMR Report')
      expect(page.has_content?(school.name)).to be true
      expect(page.has_content?(meter.mpan_mprn)).to be true

      click_on 'Download all AMR data'

      # Make sure the page is a CSV
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /filename="all-amr-readings.csv"$/

      # Then check the content
      meter.amr_validated_readings.each do |record|
        expect(page.source).to have_content Reports::AmrValidatedReadingsController::CSV_HEADER
        expect(page).to have_content amr_validated_reading_to_s(meter.amr_validated_readings.first)
      end
    end

    it 'has a report which can be viewed', js: true do
      click_on('Manage')
      click_on('Reports')
      click_on('AMR Report')
      click_on(meter.mpan_mprn)
      expect(page).to have_content 'January'
    end

    def amr_validated_reading_to_s(amr)
      "#{amr.reading_date},#{amr.one_day_kwh},#{amr.status},#{amr.substitute_date},#{amr.kwh_data_x48.join(',')}"
    end
  end
end
