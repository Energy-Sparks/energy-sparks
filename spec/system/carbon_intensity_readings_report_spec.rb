require 'rails_helper'

module DataFeeds
  RSpec.describe 'Carbon intensity readings report', type: :system do
    let!(:carbon_intensity_reading) { CarbonIntensityReading.create(reading_date: Date.parse('01/06/2019'), carbon_intensity_x48: Array.new(48, rand)) }
    let!(:admin) { create(:admin) }

    before do
      sign_in(admin)
      visit root_path
    end

    context 'with a reading' do
      it 'allows a download of all CSV data' do
        click_on('Reports')
        click_on 'Carbon intensity data CSV'

        # Make sure the page is a CSV
        header = page.response_headers['Content-Disposition']
        expect(header).to(match(/^attachment/))
        expect(header).to(match(/carbon-intensity-readings.csv$/))

        # Then check the content
        CarbonIntensityReading.all.each do |_record|
          expect(page.source).to have_content DataFeeds::CarbonIntensityReadingsController::CSV_HEADER
          expect(page).to have_content reading_to_s(carbon_intensity_reading)
        end
      end

      it 'has a report which can be viewed', js: true do
        click_on('Manage')
        click_on('Reports')
        click_on('Carbon intensity data')
        expect(page).to have_content 'January'
      end

      def reading_to_s(carbon_intensity_reading)
        "#{carbon_intensity_reading.reading_date},#{carbon_intensity_reading.carbon_intensity_x48.join(',')}"
      end
    end
  end
end
