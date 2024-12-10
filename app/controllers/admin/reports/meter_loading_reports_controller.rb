module Admin
  module Reports
    class MeterLoadingReportsController < AdminController
      def index
        @results = run_report
      end

      private

      def run_report
        if params[:mpxn].present?
          AmrDataFeedReading.meter_loading_report(params[:mpxn])
        else
          []
        end
      end
    end
  end
end
