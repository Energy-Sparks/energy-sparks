# frozen_string_literal: true

module Solar
  class SolarEdgeDownloadAndUpsert < BaseDownloadAndUpsert
    def initialize(
      installation:,
      start_date:,
      end_date:,
      reload: false
    )
      super(start_date: start_date, end_date: end_date, installation: installation)
      @reload = reload
    end

    def download_and_upsert
      return unless monitoring_active?

      SolarEdgeUpserter.new(installation: @installation, readings: all_meter_data, import_log: import_log).perform
    end

    def job
      :solar_edge_download
    end

    protected

    def latest_reading
      @installation.latest_reading
    end

    def end_date
      return nil if @reload

      super
    end

    private

    # FIXME: what about gaps?
    def start_date_for_meter(meter_type = :electricity)
      return nil if @reload

      latest_reading = @installation.latest_reading(meter_type)
      if @requested_start_date
        @requested_start_date
      elsif latest_reading.nil?
        nil
      else
        [latest_reading, Date.yesterday].min
      end
    end

    def all_meter_data
      if @installation.consented? # v2
        site_api = @installation.site_api!
        # FIXME: only try and load if meter is active on our side
        # FIXME only try and load if meter is active on SolarEdge. Requires device metadata refresh, ideally
        {
          solar_pv: { readings: solar_pv_readings(site_api) },
          exported_solar_pv: { readings: exported_solar_pv_readings(site_api) },
          electricity: { readings: electricity_readings(site_api) }
        }
      else
        solar_edge_api.smart_meter_data(
          @installation.site_id,
          start_date_for_meter,
          end_date
        )
      end
    end

    def solar_pv_readings(site_api)
      site_api.production(
        start_date: start_date_for_meter(:solar_pv),
        end_date: end_date
      )
    end

    def exported_solar_pv_readings(site_api)
      site_api.export_energy(serial_number: @installation.metadata_for_meter_type('FeedIn')['serialNumber'],
                             start_date: start_date_for_meter(:exported_solar_pv),
                             end_date: end_date)
    end

    def electricity_readings(site_api)
      site_api.import_energy(serial_number: @installation.metadata_for_meter_type('Purchased')['serialNumber'],
                             start_date: start_date_for_meter,
                             end_date: end_date)
    end

    def monitoring_active?
      return true if @installation.monitoring_active?

      # refresh local copy of site status and recheck
      SolarEdgeService.new(@installation).update_information

      @installation.monitoring_active?
    end

    def solar_edge_api
      DataFeeds::SolarEdgeApi.new(@installation.api_key)
    end
  end
end
