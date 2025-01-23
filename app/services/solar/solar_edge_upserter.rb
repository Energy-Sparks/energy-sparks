# frozen_string_literal: true

require 'dashboard'

module Solar
  class SolarEdgeUpserter < BaseUpserter
    private

    def meter_model_attributes(_details)
      { pseudo: true, solar_edge_installation: @installation }
    end

    def synthetic_mpan(meter_type, _details)
      Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(@installation.mpan, meter_type)
    end
  end
end
