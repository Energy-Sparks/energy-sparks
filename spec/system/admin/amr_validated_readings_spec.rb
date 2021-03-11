require 'rails_helper'

RSpec.describe "amr validated readings", :amr_validated_readings, type: :system do

  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school)       { create(:school,:with_school_group, name: school_name)}
  let!(:admin)        { create(:admin)}
  let!(:meter)        { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school) }

  before(:each) do
    sign_in(admin)
    visit root_path
  end

  context 'when a meter has readings' do
    before(:each) do
      click_on 'Admin'
      click_on('Reports')
      click_on('Meter Report')
      expect(page.has_content?(school.name)).to be true
      expect(page.has_content?(meter.mpan_mprn)).to be true
    end

    it 'allows a download of all Validated meter data' do
      click_on 'All validated meter data'

      # Make sure the page is a CSV
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /all-amr-validated-readings.csv$/

      # Then check the content
      meter.amr_validated_readings.each do |record|
        expect(page.source).to have_content Admin::Reports::AmrValidatedReadingsController::CSV_HEADER
        expect(page).to have_content amr_validated_reading_to_s(meter.amr_validated_readings.first)
      end
    end

    context 'raw data downloads' do
      it 'allows a download of all' do
        meter_with_raw_data = create(:electricity_meter_with_reading, name: 'Electricity meter 2', school: school)

        click_on 'Download raw meter data'

        # Make sure the page is a CSV
        header = page.response_headers['Content-Disposition']
        expect(header).to match /^attachment/
        expect(header).to match /all-amr-raw-readings.csv$/

        expect(page.source).to have_content AmrDataFeedReading::CSV_HEADER_DATA_FEED_READING

        # Then check the content
        meter_with_raw_data.amr_data_feed_readings.each do |record|
          expect(page.source).to have_content amr_data_feed_reading_to_s(meter_with_raw_data, meter_with_raw_data.amr_data_feed_readings.first)
        end
      end
    end
  end

  context 'has a rich calendar view' do
    it 'has a report which can be viewed', js: true do
      click_on('Manage')
      click_on('Reports')
      click_on('Meter Report')
      click_on(meter.mpan_mprn.to_s)
      expect(page).to have_content 'January'
    end
  end

  context 'when there are gaps in the meter readings' do

    let(:base_date) { Date.today - 1.year }

    before do
      create(:amr_validated_reading, meter: meter, reading_date: base_date, status: 'ORIG')
      15.times do |idx|
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 1 + idx.days, status: 'NOT_ORIG')
      end
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 17, status: 'ORIG')
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 18, status: 'NOT_ORIG')
    end

    it 'shows count of modified dates and gaps' do
      click_on('Manage')
      click_on('Reports')
      click_on('Meter Report')

      expect(page).to have_content 'Large gaps in last 2 years'
      expect(page).to have_content 'Modified readings in last 2 years'

      within '.gappy-dates' do
        expect(page).to have_content "15 days (#{(base_date + 1.day).to_s(:es_short)} to #{(base_date + 15.days).to_s(:es_short)})"
      end

      within '.modified-dates' do
        expect(page).to have_content '16'
      end
    end
  end
end
