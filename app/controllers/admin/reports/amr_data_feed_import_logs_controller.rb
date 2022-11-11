module Admin
  module Reports
    class AmrDataFeedImportLogsController < AdminController
      include Pagy::Backend
      before_action :set_log_counts

      def warnings
        @pagy, @logs = pagy(AmrReadingWarning.order(created_at: :desc))
      end

      def errors
        @pagy, @logs = pagy(AmrDataFeedImportLog.errored.order(import_time: :desc))
      end

      def index
        @pagy, @logs = pagy(AmrDataFeedImportLog.successful.order(import_time: :desc))
      end

      private

      def set_log_counts
        @successes_count = AmrDataFeedImportLog.successful.count
        @warnings_count = AmrReadingWarning.count
        @errors_count = AmrDataFeedImportLog.errored.count
      end
    end
  end
end
