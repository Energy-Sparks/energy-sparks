require 'rails_helper'

describe 'downloads', type: :system do
  let(:school_name)               { 'Active school'}
  let!(:school)                   { create_active_school(name: school_name)}
  let!(:teacher)                  { create(:staff, school: school)}
  let(:mpan)                      { 1234567890123 }
  let!(:meter)                    { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school, mpan_mprn: mpan) }

  def reading_row(amr)
    "#{amr.meter.mpan_mprn},#{amr.meter.meter_type.titleize},#{amr.reading_date},#{amr.one_day_kwh},#{amr.status},#{amr.substitute_date},#{amr.kwh_data_x48.join(',')}"
  end

  context 'as teacher' do
    before do
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)

      sign_in(teacher)
      visit root_path
      # this is the my school menu link
      click_link 'download-your-data'
      expect(page).to have_content("Downloads for #{school.name}")
      expect(page).to have_content(mpan)
    end

    it 'allows a full download of data' do
      click_on 'Download meter data for all meters combined'

      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
      expect(header).to match(/school-amr-readings-#{school.name.parameterize}.csv$/)

      # Then check the content
      meter.amr_validated_readings.each do |amr|
        expect(page.source).to have_content AmrValidatedReading::CSV_HEADER_FOR_SCHOOL
        expect(page).to have_content reading_row(amr)
      end
    end

    it 'allows a download of CSV for a meter' do
      click_on mpan.to_s

      # Make sure the page is a CSV
      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename=\"#{meter.mpan_mprn}-readings.csv\"/)

      # Then check the content
      meter.amr_validated_readings.each do |amr|
        expect(page.source).to have_content AmrValidatedReading::CSV_HEADER_FOR_SCHOOL
        expect(page).to have_content reading_row(amr)
      end
    end
  end

  context 'as school admin' do
    let!(:school_admin) { create(:school_admin) }
    let!(:other_school) { create(:school) }

    it 'does not allow download of other schools data' do
      sign_in(school_admin)
      visit school_downloads_path(other_school)
      expect(page).to have_content('You are not authorized to view that page')
    end
  end

  context 'as admin' do
    let!(:admin)                  { create(:admin) }
    let!(:filtered_school)        { create(:school, :with_feed_areas, name: 'Filter school') }

    before do
      sign_in(admin)
      visit school_meters_path(filtered_school)
      click_on 'School downloads'
      expect(page).to have_content("Downloads for #{filtered_school.name}")
    end

    it 'allows a download of all filtered by school' do
      filtered_meter_with_raw_data = create(:electricity_meter_with_reading, name: 'Electricity meter Filter', school: filtered_school)

      click_on 'Unvalidated meter data as CSV'

      # Make sure the page is a CSV
      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
      expect(header).to match(/#{filtered_school.name.parameterize}-amr-raw-readings.+\.csv$/)

      expect(page.source).to have_content AmrDataFeedReading::CSV_HEADER_DATA_FEED_READING

      # Then check the content
      meter.amr_data_feed_readings.each do |record|
        expect(page.source).not_to have_content amr_data_feed_reading_to_s(meter, record)
      end

      filtered_meter_with_raw_data.amr_data_feed_readings.each do |record|
        expect(page.source).to have_content amr_data_feed_reading_to_s(filtered_meter_with_raw_data, record)
      end
    end
  end
end
