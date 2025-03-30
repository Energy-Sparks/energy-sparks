require 'require_all'
require_relative '../lib/dashboard.rb'
require_relative './csv_file_support.rb'

class DownloadSheffieldSolarPVData
  include Logging

  def report_bad_data(missing_date_times, whole_day_substitutes)
    if missing_date_times.empty?
      logger.info 'No missing data'
    else
      logger.info "#{missing_date_times.length} missing items of data:"
      missing_date_times.each_slice(6) do |one_row|
        formatted_datetimes  = one_row.map { |dt| dt.strftime('%Y%b%d %H:%M') }
        logger.info "#{formatted_datetimes.join(' ')}"
      end
      unless whole_day_substitutes.empty?
        whole_day_substitutes.each do |missing_date, substitute_date|
          logger.info "Warning: not enough data on #{missing_date.strftime('%Y%b%d')} substituted from #{substitute_date.strftime('%Y%b%d')}"
        end
      end
    end
  end

  def sum_pv_data(date_to_x48)
    date_to_x48.values.flatten(1).sum
  end

  def csv_file(filename, datum_for_feed)
    start_date = datum_for_feed
    file = TestCSVFileSupport.new(filename)
    start_date = file.last_reading_date if file.exists?
    [file, start_date]
  end

  def update_solar_pv_csv_file(filename, name, latitude, longitude, datum_for_feed, end_date)
    logger.info "#{name}"

    file, start_date = csv_file(filename, datum_for_feed)

    if start_date >= end_date
      logger.info '    csv file up to date'
      return
    end

    file.backup

    pv_interface = DataSources::PVLiveService.new

    nearest = pv_interface.find_nearest_areas(latitude, longitude)

    logger.info '    5 nearest solar pv areas'
    logger.ap   nearest, indent: 8

    solar_pv_data, missing_date_times, whole_day_substitutes = pv_interface.historic_solar_pv_data(nearest.first[:gsp_id], latitude, longitude, start_date, end_date)

    logger.info "    Total yield #{sum_pv_data(solar_pv_data)}"

    file.append_lines_and_close(solar_pv_data)

    report_bad_data(missing_date_times, whole_day_substitutes)
  end

  def download
    logger.info '=' * 120
    logger.info 'SHEFFIELD SOLAR PV DOWNLOAD'
    datum_for_feed = Date.new(2014, 1, 1)
    end_date = Date.today - 1

    AreaNames::AREA_NAMES.each do |_area, location_data|
      update_solar_pv_csv_file(
        location_data[:solar_pv_filename],
        location_data[:name],
        location_data[:latitude],
        location_data[:longitude],
        datum_for_feed,
        end_date
      )
    end
  end
end
