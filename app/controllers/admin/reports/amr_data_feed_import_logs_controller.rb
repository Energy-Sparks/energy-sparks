module Admin
  module Reports
    class AmrDataFeedImportLogsController < AdminController
      include Pagy::Backend

      def index
        @errored_logs = AmrDataFeedImportLog.errored.order(import_time: :desc)
        @pagy, @successful_logs = pagy(AmrDataFeedImportLog.successful.order(import_time: :desc))
      end
    end
  end
end
