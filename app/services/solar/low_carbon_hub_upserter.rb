# frozen_string_literal: true

require 'dashboard'

module Solar
  class LowCarbonHubUpserter < BaseUpserter
    private

    def meter_model_attributes(_details)
      { pseudo: true, low_carbon_hub_installation: @installation }
    end

    def synthetic_mpan(_meter_type, details)
      details[:mpan_mprn]
    end

    def data_feed_reading_array(readings_hash, meter_id, mpan_mprn)
      super(readings_hash.transform_values(&:kwh_data_x48), meter_id, mpan_mprn)
    end
  end
end
