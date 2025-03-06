require 'rails_helper'

describe 'unvalidated readings', type: :system do
  let!(:admin)       { create(:admin) }
  let!(:config)      { create(:amr_data_feed_config, description: 'Description', date_format: '%d-%m-%Y') }
  let!(:reading)     { create(:amr_data_feed_reading, reading_date: '23-06-2023', amr_data_feed_config: config)}

  before do
    sign_in(admin)
    visit root_path
    click_on('Reports')
    click_on('Unvalidated readings')
  end

  describe 'Running report' do
    before do
      fill_in 'List', with: reading.mpan_mprn
      click_on 'Run report'
    end

    it 'displays report' do
      expect(page).to have_content reading.mpan_mprn
      expect(page).to have_content config.identifier
      expect(page).to have_content config.description
      expect(page).to have_content '2023-06-23'
      expect(page).to have_content '2023-06-23'
    end
  end

  describe 'Downloading csv' do
    before do
      freeze_time
      fill_in 'List', with: reading.mpan_mprn
      click_on 'Download CSV'
    end

    let(:lines) { page.body.lines.collect(&:chomp) }

    it 'shows csv contents' do
      expect(lines.first).to eq 'MPAN/MPRN,Config identifier,Config name,Earliest reading,Latest reading'
      expect(lines.second).to eq "#{reading.mpan_mprn},#{config.identifier},#{config.description},2023-06-23,2023-06-23"
    end

    it 'has csv content type' do
      expect(response_headers['Content-Type']).to eq 'text/csv'
    end

    it 'has expected file name' do
      expect(response_headers['Content-Disposition']).to \
        include("energy-sparks-unvalidated-readings-report-#{Time.zone.now.iso8601.tr(':', '-')}.csv")
    end
  end
end
