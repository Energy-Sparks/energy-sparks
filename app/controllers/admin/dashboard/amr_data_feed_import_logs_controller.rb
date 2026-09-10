# frozen_string_literal: true

module Admin
  module Dashboard
    class AmrDataFeedImportLogsController < Admin::Reports::AmrDataFeedImportLogsController
      include AdminDashboard

      before_action :set_user
      before_action :set_log_counts

      def index
        @amr_data_feed_configs = AmrDataFeedConfig.enabled.where(owned_by: @dashboard_user).order(:description)
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Data feed import logs' }
                          ])
      end

      def set_log_counts
        amr_data_feed_config = AmrDataFeedConfig.enabled.where(owned_by: @dashboard_user)
        @successes_count = AmrDataFeedImportLog.where(amr_data_feed_config:).successful.recent.count
        @warnings_count = AmrDataFeedImportLog.where(amr_data_feed_config:).with_warnings.recent.count
        @errors_count = AmrDataFeedImportLog.where(amr_data_feed_config:).errored.recent.count
      end
    end
  end
end
