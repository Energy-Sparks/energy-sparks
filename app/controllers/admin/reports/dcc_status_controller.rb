module Admin
  module Reports
    class DccStatusController < AdminController
      def index
        @dcc_meters = Meter.dcc.sort_by(&:school)
      end
    end
  end
end
