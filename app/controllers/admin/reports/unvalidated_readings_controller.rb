module Admin
  module Reports
    class UnvalidatedReadingsController < AdminController
      def show
        @report = run_report
      end

      private

      def run_report
        if params[:mpans].present?
          param = params[:mpans]
          if param["list"].present?
            return AmrDataFeedReading.unvalidated_data_report_for_mpans(tidy(param["list"]))
          else
            return []
          end
        end
        []
      end

      def tidy(list)
        list.split("\n").map(&:strip)
      end
    end
  end
end
