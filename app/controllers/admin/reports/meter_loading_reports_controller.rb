module Admin
  module Reports
    class MeterLoadingReportsController < AdminController
      include Pagy::Method
      def index
        @pagy, @results = pagy(run_report, limit: 30)
      end

      private

      def run_report
        if params[:mpxn].present?
          AmrDataFeedReading.meter_loading_report(params[:mpxn])
        else
          AmrDataFeedReading.none
        end
      end
    end
  end
end
