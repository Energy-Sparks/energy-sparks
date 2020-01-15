require 'dashboard'

module DataFeeds
  class SolarPvTuosV2Loader
    def initialize(start_date = Date.yesterday - 10.days, end_date = Date.yesterday, solar_pv_tuos_interface = SheffieldSolarPVV2.new)
      @start_date = start_date
      @end_date = end_date
      @solar_pv_tuos_interface = solar_pv_tuos_interface
      @insert_count = 0
      @update_count = 0
    end

    def import
      SolarPvTuosArea.all.each do |area|
        process_area(area)
      end
      p "Imported #{@insert_count} records, Updated #{@update_count} records"
    end

    def import_area(area)
      process_area(area)
      p "Imported #{@insert_count} records, Updated #{@update_count} records"
    end

  private

    def nearest_gsp_area(area)
      @solar_pv_tuos_interface.find_nearest_areas(area.latitude, area.longitude).first
    end

    def process_area(area)
      gsp_area = nearest_gsp_area(area)

      begin
        solar_pv_data, _missing_date_times, _whole_day_substitutes = @solar_pv_tuos_interface.historic_solar_pv_data(
          gsp_area[:gsp_id],
          gsp_area[:latitude],
          gsp_area[:longitude],
          @start_date,
          @end_date
        )
      rescue => e
        puts "Exception: running solar pv: #{e.class} #{e.message}"
        puts e.backtrace.join("\n")
        Rails.logger.error "Exception: running solar pv: #{e.class} #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        Rollbar.error(e)
      end

      solar_pv_data.each do |reading_date, generation_mw_x48|
        next if generation_mw_x48.size != 48
        next if reading_date.nil?
        process_day(reading_date, generation_mw_x48, area, gsp_area)
      end
    end

    def process_day(reading_date, generation_mw_x48, area, gsp_area)
      gsp_id = gsp_area[:gsp_id]
      gsp_name = gsp_area[:gsp_name]
      latitude = gsp_area[:latitude]
      longitude = gsp_area[:longitude]
      distance_km = gsp_area[:distance_km]

      record = SolarPvTuosReading.find_by(reading_date: reading_date, area_id: area.id)
      if record
        record.update(generation_mw_x48: generation_mw_x48, gsp_id: gsp_id, gsp_name: gsp_name, latitude: latitude, longitude: longitude, distance_km: distance_km)
        @update_count = @update_count + 1
      else
        SolarPvTuosReading.create!(
          reading_date: reading_date,
          generation_mw_x48: generation_mw_x48,
          gsp_id: gsp_id,
          gsp_name: gsp_name,
          latitude: latitude,
          longitude: longitude,
          area_id: area.id,
          distance_km: distance_km)
        @insert_count = @insert_count + 1
      end
    end
  end
end
