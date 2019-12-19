require 'rails_helper'

describe AmrUploadedReading, type: :system do

  let!(:admin)              { create(:admin) }
  let!(:config)             { create(:amr_data_feed_config) }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'AMR Data feed configuration'
    click_on config.description
    click_on 'Upload file'
  end

  it 'can upload a file' do
    attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-example-file.csv')
    click_on 'Preview'
    expect(page).to_not have_content('We have identified a problem')
    expect(page).to have_content('First ten rows')
    expect(page).to have_content('2200012767323')
    expect(page).to have_content('2200012030374')
    expect(page).to have_content('2200040922992')
  end

  it 'is helpful if a very different format file is loaded' do
    attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/example-sheffield-file.csv')
    click_on 'Preview'
    expect(page).to have_content(AmrReadingData::ERROR_UNABLE_TO_PARSE_FILE)
  end

  it 'is helpful if a dodgy date format file is loaded' do
    attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-bad-example-date-file.csv')
    click_on 'Preview'
    expect(page).to have_content(AmrReadingData::ERROR_BAD_DATE_FORMAT % { example: 'KABOOM' })
  end

  it 'is helpful if a dodgy mpan format file is loaded' do
    attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-bad-example-missing-mpan-file.csv')
    click_on 'Preview'
    expect(page).to have_content(AmrReadingData::ERROR_UNABLE_TO_PARSE_FILE)
  end

  it 'is helpful if a reading is missing' do
    attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-bad-example-missing-data-file.csv')
    click_on 'Preview'
    expect(page).to have_content(AmrReadingData::ERROR_MISSING_READINGS)
  end
end
