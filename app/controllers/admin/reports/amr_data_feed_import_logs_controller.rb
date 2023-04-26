module Admin
  module Reports
    class AmrDataFeedImportLogsController < AdminController
      include Pagy::Backend
      before_action :set_log_counts
      SUMMARY_PERIOD_IN_DAYS = 7

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
        @amr_data_feed_import_logs = AmrDataFeedImportLog.send(page).order(import_time: :desc)
        @amr_data_feed_import_logs = @amr_data_feed_import_logs.where("file_name ILIKE '%#{params[:search]}%'") if params[:search]
        @amr_data_feed_import_logs = @amr_data_feed_import_logs.where(amr_data_feed_config_id: params[:config][:config_id]) if params[:config] && params[:config][:config_id].present?
        @pagy, @logs = pagy(@amr_data_feed_import_logs)
      end

      def set_log_counts
        @successes_count = AmrDataFeedImportLog.successful.count
        @warnings_count = AmrDataFeedImportLog.with_warnings.count
        @errors_count = AmrDataFeedImportLog.errored.count
      end
    end
  end
end
