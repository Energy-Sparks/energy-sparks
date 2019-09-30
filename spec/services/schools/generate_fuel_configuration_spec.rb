require 'rails_helper'

module Schools
  describe GenerateFuelConfiguration do

    it 'uses the results of the calls to the analytics' do
      aggregated_meter_collection = double electricity?: true, gas?: false, solar_pv_panels?: true, storage_heaters?: false, report_group: :electric_and_solar_pv

      fuel_config = GenerateFuelConfiguration.new(aggregated_meter_collection).generate

      expect(fuel_config.fuel_types_for_analysis).to be :electric_and_solar_pv
      expect(fuel_config.has_gas).to be false
      expect(fuel_config.has_electricity).to be true
      expect(fuel_config.has_solar_pv).to be true
      expect(fuel_config.has_storage_heaters).to be false
    end

  end
end
