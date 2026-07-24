require 'rails_helper'

describe AmrDataFeedImportLog, :include_application_helper, type: :system do
  let!(:admin)            { create(:admin) }
  let!(:config)           { create(:amr_data_feed_config) }
  let!(:disabled_config)  { create(:amr_data_feed_config, description: 'Disabled', enabled: false) }
  let!(:import_log_1)     do
    create(:amr_data_feed_import_log, amr_data_feed_config: config, error_messages: 'oh no!', import_time: 1.day.ago)
  end
  let!(:import_log_2) do
    create(:amr_data_feed_import_log, amr_data_feed_config: config, records_imported: 200, import_time: 1.day.ago)
  end
  let!(:import_log_3) do
    create(:amr_data_feed_import_log, amr_data_feed_config: config, records_imported: 200, import_time: 31.days.ago)
  end

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
      expect(page).to have_text('Data Feed Import Logs')
      expect(page).to have_text('Summary of the last 30 days')
    end

    it 'includes summary counts in tabs' do
      within '.nav-tabs' do
        expect(page).to have_text('Successes 1')
        expect(page).to have_text('Warnings 0')
        expect(page).to have_text('Errors 1')
      end
    end

    it 'lists all the configs' do
      within '#import-summary-table' do
        expect(page).to have_text(config.description)
        expect(page).to have_text(disabled_config.description)
      end
    end

    it 'highlights disabled configs' do
      within '#import-summary-table tbody tr.table-warning' do
        expect(page).to have_text(disabled_config.description)
      end
    end
  end
end
