# frozen_string_literal: true

require 'rails_helper'

describe AmrDataFeedImportLog do
  describe '.recent_import_stats_for_config' do
    subject(:import_stats) { described_class.recent_import_stats_for_config(amr_data_feed_config) }

    let!(:amr_data_feed_config) { create(:amr_data_feed_config) }

    before do
      # 3 successes, 1 warning, 2 errors
      create_list(:amr_data_feed_import_log, 3, amr_data_feed_config:, records_imported: 200, import_time: 1.day.ago)
      create(:amr_data_feed_import_log, :with_warnings, amr_data_feed_config:, import_time: 1.day.ago)
      create_list(:amr_data_feed_import_log, 2, :with_errors, amr_data_feed_config:, import_time: 1.day.ago)

      # 1 outside query window
      create(:amr_data_feed_import_log, amr_data_feed_config:, records_imported: 200, import_time: 31.days.ago)
    end

    it 'returns the expected data' do
      expect(import_stats).to have_attributes(
        total_count: 6,
        successful_count: 3,
        with_warnings_count: 1,
        error_count: 2
      )
    end
  end
end
