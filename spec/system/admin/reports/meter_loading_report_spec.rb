require 'rails_helper'

describe 'meter loading report' do
  let!(:admin)       { create(:admin) }
  let!(:reading)     { create(:amr_data_feed_reading, reading_date: '2024-12-25') }

  before do
    allow_any_instance_of(S3Helper).to receive(:s3_csv_download_url).and_return('https://example.org')
    sign_in(admin)
    visit root_path
    click_on('Reports')
    click_on('Meter loading report')
  end

  it 'displays the results' do
    expect(page).to have_content('Meter Loading Report')

    fill_in('mpxn', with: reading.mpan_mprn)
    click_on 'Search'

    expect(page).to have_content(reading.reading_date)
    expect(page).to have_link(reading.amr_data_feed_import_log.file_name, href: 'https://example.org')
    expect(page).to have_link(reading.amr_data_feed_config.identifier, href: admin_amr_data_feed_config_path(reading.amr_data_feed_config))
  end
end
