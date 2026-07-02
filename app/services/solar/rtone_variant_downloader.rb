require 'dashboard'

module Solar
  class RtoneVariantDownloader
    def initialize(
        installation:,
        start_date:,
        end_date:,
        api:
      )
      @rtone_variant_installation = installation
      @low_carbon_hub_api = api
      @start_date = start_date
      @end_date = end_date
    end

    def readings
      @low_carbon_hub_api.download_by_component(
        @rtone_variant_installation.rtone_meter_id,
        @rtone_variant_installation.rtone_component_type,
        @rtone_variant_installation.meter.mpan_mprn,
        @start_date,
        @end_date
      )
    end
  end
end
