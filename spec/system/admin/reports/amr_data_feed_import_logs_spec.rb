require 'rails_helper'

describe AmrDataFeedImportLog, type: :system, include_application_helper: true do

  let!(:admin)           { create(:admin) }
  let(:sheffield_config) { create(:amr_data_feed_config, description: 'Sheffield') }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'shows an import log summary table' do
    error_messages = "Oh no!"
    log_1 = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, error_messages: error_messages, import_time: 1.day.ago)
    log_2 = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)

    click_on 'AMR File imports report'
    expect(page).to have_content('Data Feed Import Logs')
    expect(page).to have_content('Summary of the last 7 days')

    expect(page).to have_content('Successes 1')
    expect(page).to have_content('Warnings 0')
    expect(page).to have_content('Errors 1')

    expect(page).to have_content('Feed')
  end
end
