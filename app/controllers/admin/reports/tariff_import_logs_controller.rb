module Admin
  module Reports
    class TariffImportLogsController < AdminController
      include Pagy::Method

      def index
        @errored_logs = TariffImportLog.errored.by_import_time
        @pagy, @successful_logs = pagy(TariffImportLog.successful.by_import_time)
      end
    end
  end
end
