module Admin
  module Reports
    class TariffImportLogsController < AdminController
      include Pagy::Backend

      def index
        @errored_logs = TariffImportLog.errored.order(import_time: :desc)
        @pagy, @successful_logs = pagy(TariffImportLog.successful.order(import_time: :desc))
      end
    end
  end
end
