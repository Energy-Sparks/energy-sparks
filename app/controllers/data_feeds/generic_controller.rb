module DataFeeds
  class GenericController < ApplicationController
    load_and_authorize_resource

    before_action :set_up_data_feed

    def show
      area_id = params[:area_id]
      ordered_readings = @data_class.where(area_id: area_id).order(reading_date: :asc)

      @first_read = ordered_readings.first
      @reading_summary = ordered_readings.group(:reading_date, @data_class_column_name).pluck(Arel.sql("reading_date, array_length(#{@data_class_column_name}, 1)")).to_h
      @missing_array = get_missing_array(@first_read, @reading_summary)

      respond_to do |format|
        format.html { render 'data_feeds/generic/show' }
        format.json { render 'data_feeds/generic/show' }
        format.csv  { send_data CsvDownloader.readings_to_csv(@data_class.download_for_area_id(area_id), @csv_header), filename: "#{area_id}-#{@title}.csv" }
      end
    end

  private

    def get_missing_array(first_reading, reading_summary)
      return [] if first_reading.nil?
      missing_array = (first_reading.reading_date.to_date..Time.zone.today).collect do |day|
        if ! reading_summary.key?(day)
          [day, 'No readings']
        elsif reading_summary.key?(day) && reading_summary[day] < 48
          [day, 'Partial readings']
        elsif reading_summary.key?(day) && reading_summary[day] > 48
          [day, 'Too many readings!']
        end
      end
      missing_array.reject!(&:blank?)
    end

    def set_up_data_feed
    end
  end
end
