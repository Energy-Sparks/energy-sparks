require 'dashboard'

module DataFeeds
  class SolarPvTuosLoader
    def initialize(start_date = Date.yesterday - 10.days, end_date = Date.yesterday, solar_pv_tuos_interface = DataSources::PVLiveService.new)
      @start_date = start_date
      @end_date = end_date
      @solar_pv_tuos_interface = solar_pv_tuos_interface
      @insert_count = 0
      @update_count = 0
    end

    def import
      SolarPvTuosArea.active.each do |area|
        process_area(area)
      end
      p "Imported #{@insert_count} records, Updated #{@update_count} records"
    end

    def import_area(area)
      process_area(area)
      p "Imported #{@insert_count} records, Updated #{@update_count} records"
    end

    private

    def gsp_area_id(area)
      area.gsp_id.presence || nearest_gsp_area(area)[:gsp_id]
    end

    def nearest_gsp_area(area)
      @solar_pv_tuos_interface.find_areas(area.gsp_name).first
    end

    def process_area(area)
      gsp_area_id = gsp_area_id(area)
      solar_pv_data, _missing_date_times, _whole_day_substitutes = @solar_pv_tuos_interface.historic_solar_pv_data(
        gsp_area_id,
        area.latitude,
        area.longitude,
        @start_date,
        @end_date
      )
      solar_pv_data.each do |reading_date, generation_mw_x48|
        next if generation_mw_x48.size != 48
        next if reading_date.nil?

        process_day(reading_date, generation_mw_x48, area)
      end
    rescue StandardError => e
      Rails.logger.error "Exception: running solar pv for #{area.title} from #{@start_date} to #{@end_date} : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :solar_pv_tuos_area, area_id: area.id, area: area.title)
    end

    def process_day(reading_date, generation_mw_x48, area)
      record = SolarPvTuosReading.find_by(reading_date: reading_date, area_id: area.id)
      if record
        record.update(generation_mw_x48: generation_mw_x48)
        @update_count += 1
      else
        SolarPvTuosReading.create!(
          reading_date: reading_date,
          generation_mw_x48: generation_mw_x48,
          area_id: area.id
        )
        @insert_count += 1
      end
    end
  end
end
