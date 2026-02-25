module Schools
  class SolarFeedsConfigurationController < ApplicationController
    load_and_authorize_resource :school

    layout -> { Flipper.enabled?(:new_manage_school_pages) ? 'dashboards' : 'application' }

    def index
      @start_time = formatted_localised_utc_time('12pm')
      @end_time = formatted_localised_utc_time('1pm')
      @rtone_installations = @school.low_carbon_hub_installations
      @rtone_variant_installations = @school.rtone_variant_installations
      @solar_edge_installations = @school.solar_edge_installations
    end

    private

    def formatted_localised_utc_time(time_string)
      Time.find_zone('UTC').parse(time_string).localtime.strftime('%H:%M')
    end
  end
end
