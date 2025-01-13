module Admin
  module Reports
    class AmrDataFeedImportLogsController < AdminController
      include Pagy::Backend
      before_action :set_log_counts
      SUMMARY_PERIOD_IN_DAYS = 30

      def warnings
        render_for(:with_warnings)
      end

      def errors
        render_for(:errored)
      end

      def successes
        render_for(:successful)
      end

      def index
        @amr_data_feed_configs = AmrDataFeedConfig.all.order(:description)
      end

      private

      def render_for(page)
        log = AmrDataFeedImportLog.send(page).order(import_time: :desc)
        log = log.where('file_name ILIKE ?', "%#{params[:search]}%") if params[:search]
        config_id = params.dig(:config, :config_id)
        log = log.where(amr_data_feed_config_id: config_id) if config_id.present?
        @amr_data_feed_import_logs = log
        @pagy, @logs = pagy(@amr_data_feed_import_logs)
      end

      def set_log_counts
        @successes_count = AmrDataFeedImportLog.successful.since(SUMMARY_PERIOD_IN_DAYS.days.ago).count
        @warnings_count = AmrDataFeedImportLog.with_warnings.since(SUMMARY_PERIOD_IN_DAYS.days.ago).count
        @errors_count = AmrDataFeedImportLog.errored.since(SUMMARY_PERIOD_IN_DAYS.days.ago).count
      end
    end
  end
end
