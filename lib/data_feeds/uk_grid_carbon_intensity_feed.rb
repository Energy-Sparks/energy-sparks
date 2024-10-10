# frozen_string_literal: true

# downloads UK grid carbon intensity data from internet
require 'net/http'
require 'json'
require 'date'

module DataFeeds
  class UKGridCarbonIntensityFeed
    attr_reader :day_readings

    def download(start_date, end_date)
      @start_date = start_date
      @end_date = end_date

      readings = download_data(@start_date, @end_date)

      readings = check_for_missing_data(readings, @start_date, @end_date)

      @day_readings = convert_to_date_arrays(readings)
    end

    private

    def make_url(start_date, end_date)
      end_date += 1
      url = 'https://api.carbonintensity.org.uk/intensity/'
      url += "#{start_date.strftime('%Y-%m-%d')}T00:30Z/"
      url += "#{end_date.strftime('%Y-%m-%d')}T00:00Z/"
      Rails.logger.debug "URL = #{url}"
      url
    end

    def download_data_from_web(start_date, end_date)
      url = make_url(start_date, end_date)
      response = Net::HTTP.get(URI(url))
      data = JSON.parse(response)
      data['data']
    end

    # converts JSON into data[datetime] = carbon intensity
    def extract_readings(readings)
      data = {}
      readings.each do |reading|
        datetime = DateTime.parse(reading['from'])
        carbon = reading['intensity']['actual']
        if carbon.nil? # TODO(PH,8Apr2019) - consider making even more fault tolerant by interpolating, upstream the feed substitutes parameterised data if this fails
          carbon = reading['intensity']['forecast']
          Rails.logger.warn "nil carbon intensity reading for #{datetime} using forecast #{carbon} instead" unless carbon.nil?
          Rails.logger.error "No carbon intensity data for #{datetime} - will use parameterised data upstream" if carbon.nil?
        end
        carbon /= 1000.0 unless carbon.nil? # 1000.0  = convert from g/kWh to kg/kWh
        data[datetime] = carbon
      end
      data
    end

    # downloads data between date range, splitting into API max 30 day chunks and avoiding year end bug
    def download_data(start_date, end_date)
      data = {}
      (start_date..end_date).each_slice(30) do |days_30_range| # 31 day max url request, so chunk
        range_start = days_30_range.first
        range_end = days_30_range.last
        if range_start.year == range_end.year
          web_data = download_data_from_web(range_start, range_end)
        else # bug in API, doesn;t work over year boundaries
          # split query - up until year end
          web_data = download_data_from_web(range_start, Date.new(range_start.year, 12, 31))
          data = data.merge(extract_readings(web_data))
          # and after year end
          web_data = download_data_from_web(Date.new(range_end.year, 1, 1), range_end)
        end
        data = data.merge(extract_readings(web_data))
      end
      Rails.logger.info "Got #{data.length} values"
      data
    end

    # explicitly loop through expected readings, so can spot gaps in returned data;
    # midnight on year end always seems to be missing......
    def check_for_missing_data(readings, start_date, end_date)
      mins30step = (1.to_f / 48)

      start_date.to_datetime.step(end_date.to_datetime, mins30step).each do |datetime|
        next if readings.key?(datetime)

        substitute_datetime = readings.keys.bsearch { |x, _| x >= datetime }
        readings[datetime] = readings[substitute_datetime]
        Rails.logger.info "Missing reading at #{datetime} substituting #{readings[substitute_datetime]}"
      end
      readings
    end

    # convert data[datetime] = carbon into data[date] = [48x 1/2 hour carbon readings]
    def convert_to_date_arrays(readings)
      data = {}
      readings.each_slice(48) do |one_day|
        date = one_day.first[0].to_date
        data[date] = []
        one_day.each do |carbon|
          data[date].push(carbon[1])
        end
      end
      data
    end
  end
end
