require 'rails_helper'

describe AmrDataFeedImportLog, type: :system, include_application_helper: true do
  let!(:admin)            { create(:admin) }
  let!(:config)           { create(:amr_data_feed_config) }
  let!(:disabled_config)  { create(:amr_data_feed_config, description: 'Disabled', enabled: false) }
  let!(:import_log_1)     { create(:amr_data_feed_import_log, amr_data_feed_config: config, error_messages: 'oh no!', import_time: 1.day.ago) }
  let!(:import_log_2)     { create(:amr_data_feed_import_log, amr_data_feed_config: config, records_imported: 200, import_time: 1.day.ago) }
  let!(:import_log_3)     { create(:amr_data_feed_import_log, amr_data_feed_config: config, records_imported: 200, import_time: 31.days.ago) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  context 'when viewing summary report' do
    before do
      click_on 'Data feed import logs'
    end

    it 'has the expected title' do
      expect(page).to have_content('Data Feed Import Logs')
      expect(page).to have_content('Summary of the last 30 days')
    end

    it 'includes summary counts in tabs' do
      within '.nav-tabs' do
        expect(page).to have_content('Successes 1')
        expect(page).to have_content('Warnings 0')
        expect(page).to have_content('Errors 1')
      end
    end

    it 'lists all the configs' do
      within '#import-summary-table' do
        expect(page).to have_content(config.description)
        expect(page).to have_content(disabled_config.description)
      end
    end

    it 'highlights disabled configs' do
      within '#import-summary-table tbody tr.table-warning' do
        expect(page).to have_content(disabled_config.description)
      end
    end
  end
end
