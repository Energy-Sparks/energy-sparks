require 'rails_helper'

describe "downloads", type: :system do

  let(:school_name)               { 'Active school'}
  let!(:school)                   { create_active_school(name: school_name)}
  let!(:teacher)                  { create(:staff, school: school)}
  let(:mpan)                      { 1234567890123 }
  let!(:meter)                    { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school, mpan_mprn: mpan ) }

  context 'as teacher' do
    before(:each) do
      sign_in(teacher)
      visit root_path
      click_on 'Download your data'
      expect(page).to have_content("Downloads for #{school.name}")
      expect(page).to have_content(mpan)
    end

    it 'allows a full download of data' do
      click_on 'Download AMR data for all meters combined'

      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /school-amr-readings-#{school.name.parameterize}.csv$/

      # Then check the content
      meter.amr_validated_readings.each do |amr|
        expect(page.source).to have_content AmrValidatedReading::CSV_HEADER_FOR_SCHOOL
        reading_row = "#{amr.meter.mpan_mprn},#{amr.meter.meter_type.titleize},#{amr.reading_date},#{amr.one_day_kwh},#{amr.status},#{amr.substitute_date},#{amr.kwh_data_x48.join(',')}"
        expect(page).to have_content reading_row
      end
    end

    it 'allows a download of CSV for a meter' do
      click_on mpan.to_s

      # Make sure the page is a CSV
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /filename=\"meter-amr-readings-#{meter.mpan_mprn}.csv\"/

      # Then check the content
      meter.amr_validated_readings.each do |amr|
        expect(page.source).to have_content AmrValidatedReading::CSV_HEADER_FOR_METER
        expect(page).to have_content amr_validated_reading_to_s(amr)
      end
    end
  end

  context 'as admin' do

    let!(:admin)                  { create(:admin) }
    let!(:filtered_school)        { create(:school, :with_feed_areas, name: "Filter school") }

    before(:each) do
      sign_in(admin)
      visit school_path(filtered_school)
      click_on 'Download your data'
      expect(page).to have_content("Downloads for #{filtered_school.name}")
    end

    it 'allows a download of all filtered by school' do
      filtered_meter_with_raw_data = create(:electricity_meter_with_reading, name: 'Electricity meter Filter', school: filtered_school)

      click_on 'Unvalidated AMR data as CSV'

      # Make sure the page is a CSV
      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /#{filtered_school.name.parameterize}-amr-raw-readings.csv$/

      expect(page.source).to have_content AmrDataFeedReading::CSV_HEADER_DATA_FEED_READING

      # Then check the content
      meter.amr_data_feed_readings.each do |record|
        expect(page.source).to_not have_content amr_data_feed_reading_to_s(meter, record)
      end

      filtered_meter_with_raw_data.amr_data_feed_readings.each do |record|
        expect(page.source).to have_content amr_data_feed_reading_to_s(filtered_meter_with_raw_data, record)
      end
    end
  end
end
