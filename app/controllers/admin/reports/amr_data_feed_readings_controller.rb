module Admin
  module Reports
    class AmrDataFeedReadingsController < AdminController
      include CsvDownloader

      def index
        school_id = params[:school_id]

        if school_id
          school = School.find(school_id)
          send_data readings_to_csv(AmrDataFeedReading.download_query_for_school(school_id), AmrDataFeedReading::CSV_HEADER_DATA_FEED_READING), filename: "#{school.name.parameterize}-amr-raw-readings.csv"
        else
          send_data readings_to_csv(AmrDataFeedReading.download_all_data, AmrDataFeedReading::CSV_HEADER_DATA_FEED_READING), filename: "all-amr-raw-readings.csv"
        end
      end
    end
  end
end
