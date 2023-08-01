require "rails_helper"

RSpec.describe "routes for energy tariffs editor", type: :routing do
  let!(:school) { create_active_school(name: "Big School")}

  context 'routes for the school energy tariff editor' do
    it 'routes school_energy_tariffs_path to the EnergyTariff controller' do
      expect(get(school_energy_tariffs_path(school))).to route_to(
        {
          controller: 'energy_tariffs/energy_tariffs',
          action: 'index',
          school_id: 'big-school'
        }
      )
    end
  end

  context 'routes for the site settings energy tariff editor' do
    it 'routes site_settings_energy_tariffs_path to the EnergyTariff controller' do
      # expect(get(school_energy_tariffs_path(school))).to route_to(
      #   {
      #     controller: 'energy_tariffs/energy_tariffs',
      #     action: 'index',
      #     school_id: 'big-school'
      #   }
      # )
    end
  end
end
