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

  it 'shows a benchmark result run and allows the user to drill down' do
    error_messages = "Oh no!"
    log_1 = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, error_messages: error_messages, import_time: 1.day.ago)
    log_2 = create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)

    click_on 'AMR File imports report'
    expect(page).to have_content('Amr Data Feed Import Logs')
    expect(page).to have_content(nice_date_times(log_1.import_time))
    expect(page).to have_content(nice_date_times(log_2.import_time))

    expect(page).to have_content(200)
    expect(page).to have_content(error_messages)
  end
end
