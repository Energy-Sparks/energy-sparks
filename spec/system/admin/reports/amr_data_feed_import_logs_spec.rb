# frozen_string_literal: true

require 'rails_helper'

describe AmrDataFeedImportLog, :include_application_helper do
  let!(:amr_data_feed_config) { create(:amr_data_feed_config) }

  let!(:disabled_config) { create(:amr_data_feed_config, description: 'Unused', enabled: false) }

  before do
    # Can't figure out how to stub out the helper method any other way here to avoid making call to S3
    #
    # rubocop:disable-next RSpec/AnyInstance
    allow_any_instance_of(S3Helper).to receive(:s3_csv_download_url).and_return('https://example.org/s3')

    sign_in(create(:admin))
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  context 'when viewing summary report' do
    before do
      # 3 successes, 1 warning, 2 errors
      create_list(:amr_data_feed_import_log, 3, amr_data_feed_config:, records_imported: 200, import_time: 1.day.ago)
      create(:amr_data_feed_import_log, :with_warnings, amr_data_feed_config:, import_time: 1.day.ago)
      create_list(:amr_data_feed_import_log, 2, :with_errors, amr_data_feed_config:, import_time: 1.day.ago)

      # 1 outside query window
      create(:amr_data_feed_import_log, amr_data_feed_config:, records_imported: 200, import_time: 31.days.ago)

      click_on 'Data feed import logs'
    end

    it 'has the expected title' do
      expect(page).to have_text('Data Feed Import Logs')
      expect(page).to have_text('Summary of all data loads completed since')
    end

    it_behaves_like 'it contains the expected data table', aligned: false, tfoot: true do
      let(:table_id) { '#import-summary-table' }
      let(:expected_header) do
        [
          ['', 'Successes', 'Rejections', 'Errors', ''],
          ['Feed', 'Total', 'Last 24 hours', 'Previous 24 hours',
           'Total', 'Last 24 hours', 'Previous 24 hours', 'Total', 'Total']
        ]
      end
      let(:expected_rows) do
        [
          [amr_data_feed_config.description, '3', '0', '1', '1', '0', '2', '2', '6'],
          [disabled_config.description, '0', '0', '0', '0', '0', '0', '0', '0']
        ]
      end
      let(:expected_footer_rows) do
        [
          ['All Feeds', '3', '', '', '1', '', '', '2', '6']
        ]
      end
    end

    it 'shows tabs with links to other reports' do
      within '.nav-tabs' do
        expect(page).to have_text('Summary')
        expect(page).to have_text('Successes')
        expect(page).to have_text('Rejections')
        expect(page).to have_text('Errors')
      end
    end

    it 'highlights disabled configs' do
      within '#import-summary-table tbody tr.table-warning' do
        expect(page).to have_text(disabled_config.description)
      end
    end
  end

  context 'when viewing recent rejections' do
    let!(:amr_data_feed_import_log) { create(:amr_data_feed_import_log) }
    let!(:warning) do
      AmrReadingWarning.create(amr_data_feed_import_log:,
                               warning_types: [AmrReadingWarning::WARNINGS.key(:missing_readings)])
    end

    before do
      click_on 'Data feed import logs'
      click_on 'Rejections'
    end

    it 'shows the rejections' do
      expect(page).to have_text('Rejections')
      expect(page).to have_link(href: 'https://example.org/s3')
      expect(page).to have_text(amr_data_feed_import_log.import_time&.strftime('%Y-%m-%d %H:%M'))
    end
  end
end
