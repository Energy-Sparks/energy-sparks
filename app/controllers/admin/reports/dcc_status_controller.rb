module Admin
  module Reports
    class DccStatusController < AdminController
      before_action :set_consented_mpxns

      def index
        @dcc_meters = Meter.dcc.where.not(sandbox: true).sort_by(&:school)
        @schools = @dcc_meters.map(&:school).uniq
      end

      private

      def set_consented_mpxns
        @mpxns = MeterReadingsFeeds::N3rgy.new(api_key: ENV["N3RGY_API_KEY"], production: true).mpxns
        @consent_lookup_error = false
      rescue
        @mpxns = []
        @consent_lookup_error = true
      end
    end
  end
end
