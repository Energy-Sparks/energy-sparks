module Admin
  module Reports
    class UnvalidatedReadingsController < AdminController
      def show
        @report = run_report
        respond_to do |format|
          format.html
          format.csv do
            send_data csv_report(@report), filename: "#{t('common.application')}-unvalidated-readings-report-#{Time.zone.now.iso8601}".parameterize + '.csv'
          end
        end
      end

      private

      def run_report
        if params[:mpans].present?
          param = params[:mpans]
          if param["list"].present?
            mpans = tidy(param["list"])
            amr_data_feed_config_id = param['amr_data_feed_config_id'].to_i
            return AmrDataFeedReading.unvalidated_data_report_for_mpans(mpans, [amr_data_feed_config_id])
          else
            []
          end
        end
        []
      end

      def tidy(list)
        list.split("\n").map(&:strip)
      end

      def csv_report(report)
        CSV.generate(headers: true) do |csv|
          csv << ['MPAN/MPRN', 'Meter', 'Config identifier', 'Config name', 'Earliest reading', 'Latest reading']
          report.each do |row|
            csv << row.slice('mpan_mprn', 'meter_id', 'identifier', 'description', 'earliest_reading', 'latest_reading').values
          end
        end
      end
    end
  end
end
