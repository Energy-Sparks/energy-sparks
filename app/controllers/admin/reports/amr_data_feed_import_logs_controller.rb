module Admin
  module Reports
    class AmrDataFeedImportLogsController < AdminController
      include Pagy::Method

      before_action :set_log_counts

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
        log = AmrDataFeedImportLog.send(page).includes(:amr_data_feed_config, :amr_reading_warnings)
        log = log.recent.order(import_time: :desc)
        log = log.where('file_name ILIKE ?', "%#{params[:search]}%") if params[:search]
        config_id = params.dig(:config, :config_id)
        log = log.where(amr_data_feed_config_id: config_id) if config_id.present?
        @amr_data_feed_import_logs = log
        @pagy, @logs = pagy(@amr_data_feed_import_logs)
      end

      def set_log_counts
        @successes_count = AmrDataFeedImportLog.successful.recent.count
        @warnings_count = AmrDataFeedImportLog.with_warnings.recent.count
        @errors_count = AmrDataFeedImportLog.errored.recent.count
      end
    end
  end
end
