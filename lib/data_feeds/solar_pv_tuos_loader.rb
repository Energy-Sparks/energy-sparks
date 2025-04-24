require 'dashboard'

module DataFeeds
  class SolarPvTuosLoader
    def initialize(start_date = Date.yesterday - 10.days, end_date = Date.yesterday, solar_pv_tuos_interface = PvLiveService.new)
      @start_date = start_date
      @end_date = end_date
      @solar_pv_tuos_interface = solar_pv_tuos_interface
    end

    def import
      SolarPvTuosArea.active.each do |area|
        process_area(area)
      end
    end

    def import_area(area)
      process_area(area)
    end

  private

    def process_area(area)
      solar_pv_data, _missing_date_times, _whole_day_substitutes = @solar_pv_tuos_interface.historic_solar_pv_data(
        area.gsp_id,
        area.latitude,
        area.longitude,
        @start_date,
        @end_date
      )

      solar_pv_data = solar_pv_data.reject do |reading_date, generation_mw_x48|
        reading_date.nil? || generation_mw_x48.size != 48
      end

      attributes = solar_pv_data.each.map do |reading_date, generation_mw_x48|
        {
          area_id: area.id,
          reading_date: reading_date,
          generation_mw_x48: generation_mw_x48
        }
      end

       SolarPvTuosReading.upsert_all(
         attributes,
         unique_by: [:area_id, :reading_date],
         on_duplicate: :update
       )
    rescue => e
      EnergySparks::Log.exception(e, job: :solar_pv_tuos_area, start_date: @start_date, end_date: @end_date, area_id: area.id, area: area.title )
    end
  end
end
