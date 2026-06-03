# frozen_string_literal: true

require_rel './meter.rb'

module Dashboard
  class AggregateMeter < Meter
    def initialize(meter_collection:, amr_data:, type:, identifier:, name:,
                   floor_area: nil, number_of_pupils: nil,
                   solar_pv_installation: nil,
                   external_meter_id: nil,
                   dcc_meter: false,
                   constituent_meters: [],
                   meter_attributes: {})
      super(meter_collection:,
            amr_data:,
            type:,
            identifier:,
            name:,
            floor_area:,
            number_of_pupils:,
            solar_pv_installation:,
            external_meter_id:,
            dcc_meter:,
            meter_attributes:)
      @constituent_meters = constituent_meters
      @partial_meter_coverage = partial_meter_coverage_from_meters
    end

    def sheffield_simulated_solar_pv_panels?
      @sheffield_simulated_solar_pv_panels ||= constituent_meters.any?(&:sheffield_simulated_solar_pv_panels?)
    end

    def solar_pv_real_metering?
      @solar_pv_real_metering ||= constituent_meters.any?(&:solar_pv_real_metering?)
    end

    def aggregate_meter?
      true
    end

    private

    # aggregate @partial_meter_coverage meter attribute component is an array
    # of its component meters' partial_meter_coverages
    def partial_meter_coverage_from_meters
      partial_meter_coverage_list = @constituent_meters.map(&:partial_meter_coverage)
      if partial_meter_coverage_list.empty?
        nil
      else
        partial_meter_coverage_list
      end
    end
  end
end
